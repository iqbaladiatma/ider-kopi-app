package api

import (
	"crypto/sha256"
	"crypto/subtle"
	"net/mail"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"iderkopi/auth-backend/internal/security"
)

const internalAdminTokenHeader = "X-Mobile-Admin-Token"
const internalAdminActorHeader = "X-Admin-Actor-ID"

type adminAccountResponse struct {
	EmployeeID         uuid.UUID  `json:"employee_id"`
	UserID             *uuid.UUID `json:"user_id,omitempty"`
	EmployeeCode       string     `json:"employee_code"`
	FullName           string     `json:"full_name"`
	Email              string     `json:"email"`
	Brand              string     `json:"brand"`
	Department         *string    `json:"department_name,omitempty"`
	Position           *string    `json:"position_name,omitempty"`
	EmployeeActive     bool       `json:"employee_active"`
	AccountActive      *bool      `json:"account_active,omitempty"`
	MustChangePassword *bool      `json:"must_change_password,omitempty"`
	UpdatedAt          *time.Time `json:"updated_at,omitempty"`
}

type updateAdminAccountStatusRequest struct {
	Active *bool `json:"active"`
}

type resetAdminAccountPasswordRequest struct {
	NewPassword string `json:"new_password"`
}

type syncAdminAccountProfileRequest struct {
	EmployeeCode string  `json:"employee_code"`
	FullName     string  `json:"full_name"`
	Email        string  `json:"email"`
	Brand        string  `json:"brand"`
	Department   *string `json:"department_name"`
	Position     *string `json:"position_name"`
	Active       *bool   `json:"active"`
}

func internalAdminAuth(expectedToken string) fiber.Handler {
	expectedDigest := sha256.Sum256([]byte(expectedToken))
	configured := strings.TrimSpace(expectedToken) != ""
	return func(c *fiber.Ctx) error {
		providedDigest := sha256.Sum256([]byte(c.Get(internalAdminTokenHeader)))
		valid := subtle.ConstantTimeCompare(expectedDigest[:], providedDigest[:]) == 1
		if !configured || !valid {
			return fiber.NewError(fiber.StatusUnauthorized, "invalid admin credentials")
		}
		return c.Next()
	}
}

func (s *Server) listAdminAccounts(c *fiber.Ctx) error {
	rows, err := s.db.Query(c.Context(), `
		SELECT e.external_id,u.id,e.employee_code,e.full_name,e.email,e.brand,
		       e.department,e.position,e.active,u.active,u.must_change_password,u.updated_at
		FROM employees e
		LEFT JOIN users u ON u.employee_id=e.external_id
		ORDER BY e.full_name,e.employee_code`)
	if err != nil {
		return fiber.ErrInternalServerError
	}
	defer rows.Close()
	accounts := make([]adminAccountResponse, 0)
	for rows.Next() {
		var account adminAccountResponse
		if err := rows.Scan(
			&account.EmployeeID, &account.UserID, &account.EmployeeCode, &account.FullName,
			&account.Email, &account.Brand, &account.Department, &account.Position,
			&account.EmployeeActive, &account.AccountActive, &account.MustChangePassword,
			&account.UpdatedAt,
		); err != nil {
			return fiber.ErrInternalServerError
		}
		accounts = append(accounts, account)
	}
	if err := rows.Err(); err != nil {
		return fiber.ErrInternalServerError
	}
	return c.JSON(fiber.Map{"data": accounts})
}

func (s *Server) updateAdminAccountStatus(c *fiber.Ctx) error {
	actorID, requestID, err := internalAdminAuditContext(c)
	if err != nil {
		return err
	}
	employeeID, err := uuid.Parse(c.Params("employee_id"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid employee_id")
	}
	var req updateAdminAccountStatusRequest
	if err := c.BodyParser(&req); err != nil || req.Active == nil {
		return fiber.NewError(fiber.StatusBadRequest, "active is required")
	}
	tx, err := s.db.BeginTx(c.Context(), pgx.TxOptions{})
	if err != nil {
		return fiber.ErrInternalServerError
	}
	defer tx.Rollback(c.Context())
	var userID uuid.UUID
	if err := tx.QueryRow(c.Context(), `
		UPDATE users SET active=$2,updated_at=now() WHERE employee_id=$1 RETURNING id`,
		employeeID, *req.Active,
	).Scan(&userID); err != nil {
		if err == pgx.ErrNoRows {
			return fiber.NewError(fiber.StatusNotFound, "employee account not found")
		}
		return fiber.ErrInternalServerError
	}
	if _, err := tx.Exec(c.Context(), `UPDATE refresh_tokens SET revoked_at=COALESCE(revoked_at,now()) WHERE user_id=$1`, userID); err != nil {
		return fiber.ErrInternalServerError
	}
	if err := tx.Commit(c.Context()); err != nil {
		return fiber.ErrInternalServerError
	}
	s.log.Info("employee account status updated", "actor_id", actorID, "employee_id", employeeID, "active", *req.Active, "request_id", requestID)
	return c.JSON(fiber.Map{"data": fiber.Map{"employee_id": employeeID, "active": *req.Active}})
}

func (s *Server) syncAdminAccountProfile(c *fiber.Ctx) error {
	actorID, requestID, err := internalAdminAuditContext(c)
	if err != nil {
		return err
	}
	employeeID, err := uuid.Parse(c.Params("employee_id"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid employee_id")
	}
	var req syncAdminAccountProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request")
	}
	req.EmployeeCode = strings.TrimSpace(req.EmployeeCode)
	req.FullName = strings.TrimSpace(req.FullName)
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))
	req.Brand = strings.TrimSpace(req.Brand)
	req.Department = trimmedOptional(req.Department)
	req.Position = trimmedOptional(req.Position)
	parsedEmail, emailErr := mail.ParseAddress(req.Email)
	if req.EmployeeCode == "" || req.FullName == "" || req.Brand == "" || req.Active == nil ||
		emailErr != nil || parsedEmail.Address != req.Email || len(req.Email) > 254 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid employee profile")
	}

	tx, err := s.db.BeginTx(c.Context(), pgx.TxOptions{})
	if err != nil {
		return fiber.ErrInternalServerError
	}
	defer tx.Rollback(c.Context())
	result, err := tx.Exec(c.Context(), `
		UPDATE employees
		SET employee_code=$2,full_name=$3,email=$4,brand=$5,department=$6,
		    position=$7,active=$8,source_updated_at=now(),synced_at=now()
		WHERE external_id=$1`, employeeID, req.EmployeeCode, req.FullName, req.Email,
		req.Brand, req.Department, req.Position, *req.Active)
	if err != nil {
		return fiber.NewError(fiber.StatusConflict, "employee profile conflicts with another account")
	}
	if result.RowsAffected() == 0 {
		return fiber.NewError(fiber.StatusNotFound, "employee not found")
	}
	if _, err := tx.Exec(c.Context(), `
		UPDATE refresh_tokens SET revoked_at=COALESCE(revoked_at,now())
		WHERE user_id IN (SELECT id FROM users WHERE employee_id=$1)`, employeeID); err != nil {
		return fiber.ErrInternalServerError
	}
	if err := tx.Commit(c.Context()); err != nil {
		return fiber.ErrInternalServerError
	}
	s.log.Info("employee login profile synchronized", "actor_id", actorID,
		"employee_id", employeeID, "request_id", requestID)
	return c.JSON(fiber.Map{"data": fiber.Map{"employee_id": employeeID}})
}

func trimmedOptional(value *string) *string {
	if value == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}
	return &trimmed
}

func (s *Server) resetAdminAccountPassword(c *fiber.Ctx) error {
	actorID, requestID, err := internalAdminAuditContext(c)
	if err != nil {
		return err
	}
	employeeID, err := uuid.Parse(c.Params("employee_id"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid employee_id")
	}
	var req resetAdminAccountPasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request")
	}
	if err := security.ValidatePassword(req.NewPassword); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}
	hash, err := security.HashPassword(req.NewPassword, s.bcryptCost)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}
	tx, err := s.db.BeginTx(c.Context(), pgx.TxOptions{})
	if err != nil {
		return fiber.ErrInternalServerError
	}
	defer tx.Rollback(c.Context())
	var userID uuid.UUID
	if err := tx.QueryRow(c.Context(), `
		UPDATE users SET password_hash=$2,must_change_password=true,active=true,updated_at=now()
		WHERE employee_id=$1 RETURNING id`, employeeID, hash,
	).Scan(&userID); err != nil {
		if err == pgx.ErrNoRows {
			return fiber.NewError(fiber.StatusNotFound, "employee account not found")
		}
		return fiber.ErrInternalServerError
	}
	if _, err := tx.Exec(c.Context(), `UPDATE refresh_tokens SET revoked_at=COALESCE(revoked_at,now()) WHERE user_id=$1`, userID); err != nil {
		return fiber.ErrInternalServerError
	}
	if err := tx.Commit(c.Context()); err != nil {
		return fiber.ErrInternalServerError
	}
	s.log.Info("employee password reset", "actor_id", actorID, "employee_id", employeeID, "request_id", requestID)
	return c.JSON(fiber.Map{"data": fiber.Map{"employee_id": employeeID, "must_change_password": true}})
}

func internalAdminAuditContext(c *fiber.Ctx) (uuid.UUID, uuid.UUID, error) {
	actorID, actorErr := uuid.Parse(strings.TrimSpace(c.Get(internalAdminActorHeader)))
	requestID, requestErr := uuid.Parse(strings.TrimSpace(c.Get(fiber.HeaderXRequestID)))
	if actorErr != nil || requestErr != nil {
		return uuid.Nil, uuid.Nil, fiber.NewError(fiber.StatusBadRequest, "valid audit headers are required")
	}
	return actorID, requestID, nil
}
