package security

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func TestJWTClaimsAndAlgorithm(t *testing.T) {
	m, err := NewTokenManager([]byte("01234567890123456789012345678901"), time.Minute)
	if err != nil {
		t.Fatal(err)
	}
	raw, _, err := m.Issue("user-id", "employee-id", "employee@example.test", true)
	if err != nil {
		t.Fatal(err)
	}
	claims, err := m.Parse(raw)
	if err != nil {
		t.Fatal(err)
	}
	if claims.Subject != "user-id" || claims.EmployeeID != "employee-id" || !claims.MustChangePassword || claims.Issuer != Issuer {
		t.Fatalf("unexpected claims: %+v", claims)
	}

	bad := jwt.NewWithClaims(jwt.SigningMethodHS384, claims)
	signed, err := bad.SignedString([]byte("01234567890123456789012345678901"))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := m.Parse(signed); err == nil {
		t.Fatal("accepted non-HS256 token")
	}
}

func TestRefreshTokenHash(t *testing.T) {
	plain, hash, err := NewRefreshToken()
	if err != nil {
		t.Fatal(err)
	}
	if plain == "" || hash != HashRefreshToken(plain) {
		t.Fatal("refresh token hash mismatch")
	}
}
