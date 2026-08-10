package api

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"log/slog"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/helmet"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"

	"iderkopi/auth-backend/internal/security"
)

const principalKey = "principal"

type Server struct {
	db         *pgxpool.Pool
	tokens     *security.TokenManager
	refreshTTL time.Duration
	bcryptCost int
	dummyHash  []byte
	log        *slog.Logger
}

type principal struct {
	UserID             uuid.UUID
	EmployeeID         uuid.UUID
	EmployeeCode       string
	FullName           string
	Email              string
	Brand              string
	Department         *string
	Position           *string
	MustChangePassword bool
}

func New(db *pgxpool.Pool, tokens *security.TokenManager, refreshTTL time.Duration, bcryptCost int, corsAllowOrigins, adminToken string, logger *slog.Logger) (*fiber.App, error) {
	dummyInput := make([]byte, 32)
	if _, err := rand.Read(dummyInput); err != nil {
		return nil, err
	}
	dummyHash, err := bcrypt.GenerateFromPassword([]byte(base64.RawURLEncoding.EncodeToString(dummyInput)), bcryptCost)
	if err != nil {
		return nil, err
	}
	s := &Server{db: db, tokens: tokens, refreshTTL: refreshTTL, bcryptCost: bcryptCost, dummyHash: dummyHash, log: logger}
	app := fiber.New(fiber.Config{
		AppName: "iderkopi-mobile-auth", BodyLimit: 1 << 20,
		ReadTimeout: 10 * time.Second, WriteTimeout: 10 * time.Second, IdleTimeout: 30 * time.Second,
		DisableStartupMessage: true, EnableTrustedProxyCheck: false,
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			message := "internal server error"
			var fiberErr *fiber.Error
			if errors.As(err, &fiberErr) {
				code, message = fiberErr.Code, fiberErr.Message
			}
			if code >= 500 {
				logger.Error("request failed", "request_id", c.GetRespHeader(fiber.HeaderXRequestID), "error", err)
			}
			return c.Status(code).JSON(fiber.Map{"error": message})
		},
	})
	app.Use(recover.New(), requestid.New(), helmet.New(helmet.Config{ContentSecurityPolicy: "default-src 'none'; frame-ancestors 'none'"}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: corsAllowOrigins,
		AllowMethods: fiber.MethodGet + "," + fiber.MethodPost + "," + fiber.MethodPut + "," + fiber.MethodOptions,
		AllowHeaders: fiber.HeaderContentType + "," + fiber.HeaderAuthorization,
		MaxAge:       600,
	}))
	app.Get("/health", s.health)
	authRate := limiter.New(limiter.Config{Max: 10, Expiration: time.Minute, LimitReached: func(c *fiber.Ctx) error { return fiber.NewError(fiber.StatusTooManyRequests, "too many requests") }})
	api := app.Group("/api/v1/auth")
	api.Post("/login", authRate, s.login)
	api.Post("/refresh", authRate, s.refresh)
	protected := api.Group("", s.authenticate)
	protected.Post("/logout", s.logout)
	protected.Post("/change-password", s.changePassword)
	// /me remains available while first-login password change is pending so
	// Flutter can restore the forced-change state after a restart.
	protected.Get("/me", s.me)
	internalAdmin := app.Group("/internal/admin", internalAdminAuth(adminToken))
	internalAdmin.Get("/accounts", s.listAdminAccounts)
	internalAdmin.Put("/accounts/:employee_id/status", s.updateAdminAccountStatus)
	internalAdmin.Post("/accounts/:employee_id/reset-password", s.resetAdminAccountPassword)
	return app, nil
}

func (s *Server) health(c *fiber.Ctx) error {
	ctx, cancel := context.WithTimeout(c.Context(), 2*time.Second)
	defer cancel()
	if err := s.db.Ping(ctx); err != nil {
		return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{"status": "unavailable"})
	}
	return c.JSON(fiber.Map{"status": "ok"})
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type sessionResponse struct {
	AccessToken        string       `json:"access_token"`
	RefreshToken       string       `json:"refresh_token"`
	TokenType          string       `json:"token_type"`
	ExpiresAt          string       `json:"expires_at"`
	MustChangePassword bool         `json:"must_change_password"`
	User               userResponse `json:"user"`
}

type userResponse struct {
	ID                 uuid.UUID `json:"id"`
	EmployeeID         uuid.UUID `json:"employee_id"`
	EmployeeCode       string    `json:"employee_code"`
	FullName           string    `json:"full_name"`
	Email              string    `json:"email"`
	Brand              string    `json:"brand"`
	Department         *string   `json:"department_name,omitempty"`
	Position           *string   `json:"position_name,omitempty"`
	Role               string    `json:"role"`
	MustChangePassword bool      `json:"must_change_password"`
}

func (p principal) response() userResponse {
	return userResponse{
		ID: p.UserID, EmployeeID: p.EmployeeID, EmployeeCode: p.EmployeeCode,
		FullName: p.FullName, Email: p.Email, Brand: p.Brand,
		Department: p.Department, Position: p.Position,
		Role: "employee", MustChangePassword: p.MustChangePassword,
	}
}

func (s *Server) login(c *fiber.Ctx) error {
	var req loginRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request")
	}
	email := strings.ToLower(strings.TrimSpace(req.Email))
	if email == "" || req.Password == "" {
		return fiber.NewError(fiber.StatusBadRequest, "email and password are required")
	}
	var p principal
	var passwordHash string
	err := s.db.QueryRow(c.Context(), `
		SELECT u.id, e.external_id, e.employee_code, e.full_name, e.email, e.brand,
		       e.department, e.position, u.password_hash, u.must_change_password
		FROM users u JOIN employees e ON e.external_id=u.employee_id JOIN roles r ON r.id=u.role_id
		WHERE e.email=$1 AND e.active AND u.active AND r.name='employee'`, email).
		Scan(&p.UserID, &p.EmployeeID, &p.EmployeeCode, &p.FullName, &p.Email, &p.Brand,
			&p.Department, &p.Position, &passwordHash, &p.MustChangePassword)
	if err != nil {
		_ = bcrypt.CompareHashAndPassword(s.dummyHash, []byte(req.Password))
		return fiber.NewError(fiber.StatusUnauthorized, "invalid credentials")
	}
	if !security.VerifyPassword(passwordHash, req.Password) {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid credentials")
	}
	response, err := s.createSession(c.Context(), p)
	if err != nil {
		return err
	}
	return c.JSON(fiber.Map{"data": response})
}

func (s *Server) createSession(ctx context.Context, p principal) (sessionResponse, error) {
	access, expires, err := s.tokens.Issue(p.UserID.String(), p.EmployeeID.String(), p.Email, p.MustChangePassword)
	if err != nil {
		return sessionResponse{}, fiber.ErrInternalServerError
	}
	refresh, hash, err := security.NewRefreshToken()
	if err != nil {
		return sessionResponse{}, fiber.ErrInternalServerError
	}
	_, err = s.db.Exec(ctx, `INSERT INTO refresh_tokens(id,user_id,token_hash,expires_at) VALUES($1,$2,$3,$4)`, uuid.New(), p.UserID, hash[:], time.Now().UTC().Add(s.refreshTTL))
	if err != nil {
		return sessionResponse{}, fiber.ErrInternalServerError
	}
	return sessionResponse{
		AccessToken: access, RefreshToken: refresh, TokenType: "Bearer",
		ExpiresAt: expires.Format(time.RFC3339), MustChangePassword: p.MustChangePassword,
		User: p.response(),
	}, nil
}

func (s *Server) refresh(c *fiber.Ctx) error {
	var req refreshRequest
	if err := c.BodyParser(&req); err != nil || strings.TrimSpace(req.RefreshToken) == "" {
		return fiber.NewError(fiber.StatusBadRequest, "refresh_token is required")
	}
	hash := security.HashRefreshToken(req.RefreshToken)
	tx, err := s.db.BeginTx(c.Context(), pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return fiber.ErrInternalServerError
	}
	defer tx.Rollback(c.Context())
	var oldID uuid.UUID
	var p principal
	err = tx.QueryRow(c.Context(), `
		SELECT rt.id,u.id,e.external_id,e.employee_code,e.full_name,e.email,e.brand,
		       e.department,e.position,u.must_change_password
		FROM refresh_tokens rt JOIN users u ON u.id=rt.user_id JOIN employees e ON e.external_id=u.employee_id JOIN roles r ON r.id=u.role_id
		WHERE rt.token_hash=$1 AND rt.revoked_at IS NULL AND rt.expires_at>now() AND u.active AND e.active AND r.name='employee'
		FOR UPDATE OF rt`, hash[:]).Scan(&oldID, &p.UserID, &p.EmployeeID, &p.EmployeeCode,
		&p.FullName, &p.Email, &p.Brand, &p.Department, &p.Position, &p.MustChangePassword)
	if err != nil {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid refresh token")
	}
	access, expires, err := s.tokens.Issue(p.UserID.String(), p.EmployeeID.String(), p.Email, p.MustChangePassword)
	if err != nil {
		return fiber.ErrInternalServerError
	}
	plain, newHash, err := security.NewRefreshToken()
	if err != nil {
		return fiber.ErrInternalServerError
	}
	newID := uuid.New()
	if _, err = tx.Exec(c.Context(), `INSERT INTO refresh_tokens(id,user_id,token_hash,expires_at) VALUES($1,$2,$3,$4)`, newID, p.UserID, newHash[:], time.Now().UTC().Add(s.refreshTTL)); err != nil {
		return fiber.ErrInternalServerError
	}
	if _, err = tx.Exec(c.Context(), `UPDATE refresh_tokens SET revoked_at=now(),replaced_by=$2 WHERE id=$1`, oldID, newID); err != nil {
		return fiber.ErrInternalServerError
	}
	if err = tx.Commit(c.Context()); err != nil {
		return fiber.ErrInternalServerError
	}
	return c.JSON(fiber.Map{"data": sessionResponse{
		AccessToken: access, RefreshToken: plain, TokenType: "Bearer",
		ExpiresAt: expires.Format(time.RFC3339), MustChangePassword: p.MustChangePassword,
		User: p.response(),
	}})
}

func (s *Server) authenticate(c *fiber.Ctx) error {
	header := c.Get(fiber.HeaderAuthorization)
	claims, err := parseAuthorization(s.tokens, header)
	if err != nil {
		return err
	}
	userID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid access token")
	}
	var p principal
	err = s.db.QueryRow(c.Context(), `
		SELECT u.id,e.external_id,e.employee_code,e.full_name,e.email,e.brand,
		       e.department,e.position,u.must_change_password
		FROM users u JOIN employees e ON e.external_id=u.employee_id
		WHERE u.id=$1 AND u.active AND e.active`, userID).
		Scan(&p.UserID, &p.EmployeeID, &p.EmployeeCode, &p.FullName, &p.Email,
			&p.Brand, &p.Department, &p.Position, &p.MustChangePassword)
	if err != nil || p.EmployeeID.String() != claims.EmployeeID || p.Email != claims.Email {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid access token")
	}
	c.Locals(principalKey, p)
	return c.Next()
}

func parseAuthorization(tokens *security.TokenManager, header string) (*security.Claims, error) {
	parts := strings.Split(header, " ")
	if len(parts) != 2 || parts[0] != "Bearer" || strings.TrimSpace(parts[1]) == "" {
		return nil, fiber.NewError(fiber.StatusUnauthorized, "authentication required")
	}
	claims, err := tokens.Parse(parts[1])
	if err != nil {
		return nil, fiber.NewError(fiber.StatusUnauthorized, "invalid access token")
	}
	return claims, nil
}

func (s *Server) requirePasswordChanged(c *fiber.Ctx) error {
	if c.Locals(principalKey).(principal).MustChangePassword {
		return fiber.NewError(fiber.StatusForbidden, "password change required")
	}
	return c.Next()
}

func (s *Server) logout(c *fiber.Ctx) error {
	var req refreshRequest
	if err := c.BodyParser(&req); err != nil || strings.TrimSpace(req.RefreshToken) == "" {
		return fiber.NewError(fiber.StatusBadRequest, "refresh_token is required")
	}
	p := c.Locals(principalKey).(principal)
	hash := security.HashRefreshToken(req.RefreshToken)
	_, err := s.db.Exec(c.Context(), `UPDATE refresh_tokens SET revoked_at=COALESCE(revoked_at,now()) WHERE user_id=$1 AND token_hash=$2`, p.UserID, hash[:])
	if err != nil {
		return fiber.ErrInternalServerError
	}
	return c.SendStatus(fiber.StatusNoContent)
}

type changePasswordRequest struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}

func (s *Server) changePassword(c *fiber.Ctx) error {
	var req changePasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request")
	}
	if req.CurrentPassword == req.NewPassword {
		return fiber.NewError(fiber.StatusBadRequest, "new password must be different")
	}
	if err := security.ValidatePassword(req.NewPassword); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}
	p := c.Locals(principalKey).(principal)
	tx, err := s.db.BeginTx(c.Context(), pgx.TxOptions{})
	if err != nil {
		return fiber.ErrInternalServerError
	}
	defer tx.Rollback(c.Context())
	var oldHash string
	if err := tx.QueryRow(c.Context(), `SELECT password_hash FROM users WHERE id=$1 FOR UPDATE`, p.UserID).Scan(&oldHash); err != nil {
		return fiber.ErrInternalServerError
	}
	if !security.VerifyPassword(oldHash, req.CurrentPassword) {
		return fiber.NewError(fiber.StatusUnauthorized, "current password is incorrect")
	}
	newHash, err := security.HashPassword(req.NewPassword, s.bcryptCost)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}
	if _, err = tx.Exec(c.Context(), `UPDATE users SET password_hash=$2,must_change_password=false,updated_at=now() WHERE id=$1`, p.UserID, newHash); err != nil {
		return fiber.ErrInternalServerError
	}
	if _, err = tx.Exec(c.Context(), `UPDATE refresh_tokens SET revoked_at=COALESCE(revoked_at,now()) WHERE user_id=$1`, p.UserID); err != nil {
		return fiber.ErrInternalServerError
	}
	if err = tx.Commit(c.Context()); err != nil {
		return fiber.ErrInternalServerError
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (s *Server) me(c *fiber.Ctx) error {
	p := c.Locals(principalKey).(principal)
	return c.JSON(fiber.Map{"data": p.response()})
}
