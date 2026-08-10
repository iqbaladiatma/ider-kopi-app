package config

import (
	"errors"
	"fmt"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	DatabaseURL      string
	JWTSecret        []byte
	AdminToken       string
	AccessTokenTTL   time.Duration
	RefreshTokenTTL  time.Duration
	BcryptCost       int
	CORSAllowOrigins string
	EmployeeURL      string
	EmployeeToken    string
}

func Load(command string) (Config, error) {
	c := Config{}
	var err error
	if c.DatabaseURL, err = required("MOBILE_AUTH_DATABASE_URL"); err != nil {
		return c, err
	}

	if command == "serve" {
		if c.AdminToken, err = required("MOBILE_AUTH_ADMIN_TOKEN"); err != nil {
			return c, err
		}
		if len(c.AdminToken) < 32 {
			return c, errors.New("MOBILE_AUTH_ADMIN_TOKEN must be at least 32 characters")
		}
		c.CORSAllowOrigins = strings.TrimSpace(os.Getenv("MOBILE_AUTH_CORS_ALLOW_ORIGINS"))
		if c.CORSAllowOrigins == "" {
			c.CORSAllowOrigins = "http://localhost:9100,http://127.0.0.1:9100,http://100.90.46.31:9100"
		}
		secret, err := required("MOBILE_AUTH_JWT_SECRET")
		if err != nil {
			return c, err
		}
		if len(secret) < 32 {
			return c, errors.New("MOBILE_AUTH_JWT_SECRET must be at least 32 characters")
		}
		c.JWTSecret = []byte(secret)
		if c.AccessTokenTTL, err = requiredDuration("MOBILE_AUTH_ACCESS_TOKEN_TTL"); err != nil {
			return c, err
		}
		if c.RefreshTokenTTL, err = requiredDuration("MOBILE_AUTH_REFRESH_TOKEN_TTL"); err != nil {
			return c, err
		}
	}
	if command == "serve" || command == "provision_accounts" || command == "reset_employee_passwords" {
		if c.BcryptCost, err = requiredInt("MOBILE_AUTH_BCRYPT_COST", 10, 15); err != nil {
			return c, err
		}
	}
	if command == "sync_employees" {
		if c.EmployeeURL, err = required("EMPLOYEE_SOURCE_URL"); err != nil {
			return c, err
		}
		u, parseErr := url.Parse(c.EmployeeURL)
		if parseErr != nil || u.Host == "" || u.User != nil || !allowedEmployeeSourceURL(u) {
			return c, errors.New("EMPLOYEE_SOURCE_URL must use HTTPS or an approved local Docker HTTP host")
		}
		if c.EmployeeToken, err = required("EMPLOYEE_SOURCE_TOKEN"); err != nil {
			return c, err
		}
	}
	return c, nil
}

func allowedEmployeeSourceURL(u *url.URL) bool {
	if u.Scheme == "https" {
		return true
	}
	if u.Scheme != "http" {
		return false
	}
	host := strings.ToLower(u.Hostname())
	return host == "host.docker.internal" || host == "iderkopi-backend" || host == "localhost" || host == "127.0.0.1"
}

func required(name string) (string, error) {
	v := strings.TrimSpace(os.Getenv(name))
	if v == "" {
		return "", fmt.Errorf("required environment variable %s is not set", name)
	}
	return v, nil
}

func requiredDuration(name string) (time.Duration, error) {
	v, err := required(name)
	if err != nil {
		return 0, err
	}
	d, err := time.ParseDuration(v)
	if err != nil || d <= 0 {
		return 0, fmt.Errorf("%s must be a positive duration", name)
	}
	return d, nil
}

func requiredInt(name string, min, max int) (int, error) {
	v, err := required(name)
	if err != nil {
		return 0, err
	}
	n, err := strconv.Atoi(v)
	if err != nil || n < min || n > max {
		return 0, fmt.Errorf("%s must be an integer from %d to %d", name, min, max)
	}
	return n, nil
}
