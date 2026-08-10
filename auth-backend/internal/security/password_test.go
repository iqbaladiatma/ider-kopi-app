package security

import (
	"testing"

	"golang.org/x/crypto/bcrypt"
)

func TestValidatePassword(t *testing.T) {
	for _, tc := range []struct {
		name, password string
		valid          bool
	}{
		{"simple lowercase and number", "kopiku123", true},
		{"simple lowercase only", "adminhebat", true},
		{"short", "kopi123", false},
		{"whitespace", "kopi hebat", false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if got := ValidatePassword(tc.password) == nil; got != tc.valid {
				t.Fatalf("valid=%v, want %v", got, tc.valid)
			}
		})
	}
}

func TestHashAndVerifyPassword(t *testing.T) {
	hash, err := HashPassword("Correct-Horse7!", bcrypt.MinCost)
	if err != nil {
		t.Fatal(err)
	}
	if !VerifyPassword(hash, "Correct-Horse7!") || VerifyPassword(hash, "Wrong-Horse77!") {
		t.Fatal("password verification mismatch")
	}
}
