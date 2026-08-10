package security

import (
	"errors"
	"strings"
	"unicode"
	"unicode/utf8"

	"golang.org/x/crypto/bcrypt"
)

const (
	MinPasswordRunes = 8
	MaxPasswordBytes = 72
)

func ValidatePassword(password string) error {
	if len(password) > MaxPasswordBytes {
		return errors.New("password exceeds 72 bytes")
	}
	if utf8.RuneCountInString(password) < MinPasswordRunes {
		return errors.New("password must contain at least 8 characters")
	}
	for _, r := range password {
		if unicode.IsSpace(r) {
			return errors.New("password must not contain whitespace")
		}
	}
	return nil
}

func HashPassword(password string, cost int) (string, error) {
	if err := ValidatePassword(password); err != nil {
		return "", err
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), cost)
	return string(hash), err
}

func VerifyPassword(hash, password string) bool {
	if hash == "" || strings.TrimSpace(password) == "" || len(password) > MaxPasswordBytes {
		return false
	}
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}
