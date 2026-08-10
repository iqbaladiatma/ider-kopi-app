package api

import (
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"iderkopi/auth-backend/internal/security"
)

func TestParseAuthorization(t *testing.T) {
	tokens, err := security.NewTokenManager([]byte("01234567890123456789012345678901"), time.Minute)
	if err != nil {
		t.Fatal(err)
	}
	raw, _, err := tokens.Issue("b81cf24f-2328-4f47-849c-e93c51a4c20d", "440f2495-ee75-433f-a526-f10847867874", "employee@example.test", false)
	if err != nil {
		t.Fatal(err)
	}
	claims, err := parseAuthorization(tokens, "Bearer "+raw)
	if err != nil || claims.Email != "employee@example.test" {
		t.Fatalf("valid bearer token rejected: %v", err)
	}
	for _, header := range []string{"", "bearer " + raw, "Bearer", "Bearer " + raw + " extra", "Basic " + raw} {
		if _, err := parseAuthorization(tokens, header); err == nil {
			t.Fatalf("accepted invalid authorization header %q", header)
		}
	}
}

func TestCORSPreflight(t *testing.T) {
	tokens, err := security.NewTokenManager([]byte("01234567890123456789012345678901"), time.Minute)
	if err != nil {
		t.Fatal(err)
	}
	app, err := New(nil, tokens, time.Hour, 10, "http://100.90.46.31:9100", "01234567890123456789012345678901", slog.New(slog.NewTextHandler(io.Discard, nil)))
	if err != nil {
		t.Fatal(err)
	}

	request := httptest.NewRequest(http.MethodOptions, "/api/v1/auth/login", nil)
	request.Header.Set("Origin", "http://100.90.46.31:9100")
	request.Header.Set("Access-Control-Request-Method", http.MethodPost)
	request.Header.Set("Access-Control-Request-Headers", "content-type")
	response, err := app.Test(request)
	if err != nil {
		t.Fatal(err)
	}
	if response.StatusCode != http.StatusNoContent {
		t.Fatalf("preflight status=%d, want %d", response.StatusCode, http.StatusNoContent)
	}
	if got := response.Header.Get("Access-Control-Allow-Origin"); got != "http://100.90.46.31:9100" {
		t.Fatalf("allow origin=%q", got)
	}

	blocked := httptest.NewRequest(http.MethodOptions, "/api/v1/auth/login", nil)
	blocked.Header.Set("Origin", "https://attacker.invalid")
	blocked.Header.Set("Access-Control-Request-Method", http.MethodPost)
	blockedResponse, err := app.Test(blocked)
	if err != nil {
		t.Fatal(err)
	}
	if got := blockedResponse.Header.Get("Access-Control-Allow-Origin"); got != "" {
		t.Fatalf("unexpected CORS access for disallowed origin: %q", got)
	}
}

func TestInternalAdminAuthFailsClosed(t *testing.T) {
	tokens, err := security.NewTokenManager([]byte("01234567890123456789012345678901"), time.Minute)
	if err != nil {
		t.Fatal(err)
	}
	app, err := New(nil, tokens, time.Hour, 10, "http://localhost:9100", "01234567890123456789012345678901", slog.New(slog.NewTextHandler(io.Discard, nil)))
	if err != nil {
		t.Fatal(err)
	}

	for _, token := range []string{"", "wrong-token"} {
		request := httptest.NewRequest(http.MethodGet, "/internal/admin/accounts", nil)
		request.Header.Set(internalAdminTokenHeader, token)
		response, err := app.Test(request)
		if err != nil {
			t.Fatal(err)
		}
		if response.StatusCode != http.StatusUnauthorized {
			t.Fatalf("token %q status=%d, want %d", token, response.StatusCode, http.StatusUnauthorized)
		}
	}
}
