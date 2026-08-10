package security

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const Issuer = "iderkopi-mobile-auth"

type Claims struct {
	EmployeeID         string `json:"employee_id"`
	Email              string `json:"email"`
	Role               string `json:"role"`
	MustChangePassword bool   `json:"must_change_password"`
	jwt.RegisteredClaims
}

type TokenManager struct {
	secret []byte
	ttl    time.Duration
	now    func() time.Time
}

func NewTokenManager(secret []byte, ttl time.Duration) (*TokenManager, error) {
	if len(secret) < 32 {
		return nil, errors.New("JWT secret must be at least 32 bytes")
	}
	if ttl <= 0 {
		return nil, errors.New("access token TTL must be positive")
	}
	return &TokenManager{secret: append([]byte(nil), secret...), ttl: ttl, now: time.Now}, nil
}

func (m *TokenManager) Issue(userID, employeeID, email string, mustChange bool) (string, time.Time, error) {
	now := m.now().UTC()
	expires := now.Add(m.ttl)
	claims := Claims{
		EmployeeID: employeeID, Email: email, Role: "employee", MustChangePassword: mustChange,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer: Issuer, Subject: userID, IssuedAt: jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now), ExpiresAt: jwt.NewNumericDate(expires),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(m.secret)
	return signed, expires, err
}

func (m *TokenManager) Parse(raw string) (*Claims, error) {
	claims := &Claims{}
	token, err := jwt.ParseWithClaims(raw, claims, func(token *jwt.Token) (any, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, fmt.Errorf("unexpected signing method")
		}
		return m.secret, nil
	}, jwt.WithIssuer(Issuer), jwt.WithExpirationRequired(), jwt.WithIssuedAt())
	if err != nil || !token.Valid || claims.Subject == "" || claims.EmployeeID == "" || claims.Email == "" || claims.Role != "employee" {
		return nil, errors.New("invalid access token")
	}
	return claims, nil
}

func NewRefreshToken() (plain string, hash [32]byte, err error) {
	raw := make([]byte, 32)
	if _, err = rand.Read(raw); err != nil {
		return "", hash, fmt.Errorf("generate refresh token: %w", err)
	}
	plain = base64.RawURLEncoding.EncodeToString(raw)
	hash = sha256.Sum256([]byte(plain))
	return plain, hash, nil
}

func HashRefreshToken(plain string) [32]byte { return sha256.Sum256([]byte(plain)) }
