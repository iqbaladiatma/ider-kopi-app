package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/term"

	"iderkopi/auth-backend/internal/api"
	"iderkopi/auth-backend/internal/config"
	"iderkopi/auth-backend/internal/employees"
	"iderkopi/auth-backend/internal/provision"
	"iderkopi/auth-backend/internal/security"
	"iderkopi/auth-backend/migrations"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelInfo}))
	if err := run(logger, os.Args[1:]); err != nil {
		logger.Error("command failed", "error", err)
		os.Exit(1)
	}
}

func run(logger *slog.Logger, args []string) error {
	command := "serve"
	if len(args) > 0 {
		command, args = args[0], args[1:]
	}
	switch command {
	case "serve", "migrate", "sync_employees", "provision_accounts", "reset_employee_passwords":
	default:
		return fmt.Errorf("unknown command %q", command)
	}
	cfg, err := config.Load(command)
	if err != nil {
		return err
	}
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	if command == "migrate" {
		if len(args) != 0 {
			return errors.New("migrate accepts no arguments")
		}
		conn, err := pgx.Connect(ctx, cfg.DatabaseURL)
		if err != nil {
			return fmt.Errorf("connect to auth database: %w", err)
		}
		defer conn.Close(context.Background())
		if err := migrations.Run(ctx, conn); err != nil {
			return err
		}
		logger.Info("database migrations complete")
		return nil
	}

	poolConfig, err := pgxpool.ParseConfig(cfg.DatabaseURL)
	if err != nil {
		return errors.New("invalid MOBILE_AUTH_DATABASE_URL")
	}
	poolConfig.MaxConns = 10
	poolConfig.MinConns = 1
	poolConfig.MaxConnLifetime = 30 * time.Minute
	poolConfig.MaxConnIdleTime = 5 * time.Minute
	db, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return fmt.Errorf("create auth database pool: %w", err)
	}
	defer db.Close()
	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := db.Ping(pingCtx); err != nil {
		return fmt.Errorf("connect to auth database: %w", err)
	}

	switch command {
	case "serve":
		if len(args) != 0 {
			return errors.New("serve accepts no arguments")
		}
		tokens, err := security.NewTokenManager(cfg.JWTSecret, cfg.AccessTokenTTL)
		if err != nil {
			return err
		}
		app, err := api.New(db, tokens, cfg.RefreshTokenTTL, cfg.BcryptCost, cfg.CORSAllowOrigins, cfg.AdminToken, logger)
		if err != nil {
			return fmt.Errorf("initialize API: %w", err)
		}
		listenErr := make(chan error, 1)
		go func() { listenErr <- app.Listen("0.0.0.0:2027") }()
		logger.Info("auth API listening", "port", 2027)
		select {
		case err := <-listenErr:
			return err
		case <-ctx.Done():
			shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer shutdownCancel()
			return app.ShutdownWithContext(shutdownCtx)
		}
	case "sync_employees":
		return runSync(ctx, db, cfg, args)
	case "provision_accounts":
		return runProvision(ctx, db, cfg, args)
	case "reset_employee_passwords":
		return runResetEmployeePasswords(ctx, db, cfg, args)
	}
	return nil
}

func applyFlag(command string, args []string) (bool, error) {
	flags := flag.NewFlagSet(command, flag.ContinueOnError)
	flags.SetOutput(os.Stderr)
	apply := flags.Bool("apply", false, "apply the planned changes")
	if err := flags.Parse(args); err != nil {
		return false, err
	}
	if flags.NArg() != 0 {
		return false, fmt.Errorf("%s accepts only --apply", command)
	}
	return *apply, nil
}

func runSync(ctx context.Context, db *pgxpool.Pool, cfg config.Config, args []string) error {
	apply, err := applyFlag("sync_employees", args)
	if err != nil {
		return err
	}
	incoming, err := employees.NewSource(cfg.EmployeeURL, cfg.EmployeeToken).Fetch(ctx)
	if err != nil {
		return err
	}
	current, err := employees.LoadCurrent(ctx, db)
	if err != nil {
		return err
	}
	report := employees.Plan(current, incoming)
	if len(report.Conflicts) > 0 {
		_ = json.NewEncoder(os.Stdout).Encode(report)
		return errors.New("employee sync plan contains conflicts; no changes applied")
	}
	if apply {
		if err := employees.Apply(ctx, db, incoming); err != nil {
			return err
		}
		report.Applied = true
	}
	return json.NewEncoder(os.Stdout).Encode(report)
}

func runProvision(ctx context.Context, db *pgxpool.Pool, cfg config.Config, args []string) error {
	apply, err := applyFlag("provision_accounts", args)
	if err != nil {
		return err
	}
	if !apply {
		report, err := provision.Preview(ctx, db)
		if err != nil {
			return err
		}
		return json.NewEncoder(os.Stdout).Encode(report)
	}
	password, err := initialPassword()
	if err != nil {
		return err
	}
	hash, err := security.HashPassword(password, cfg.BcryptCost)
	password = ""
	if err != nil {
		return fmt.Errorf("initial password does not meet policy: %w", err)
	}
	report, err := provision.Apply(ctx, db, hash)
	if err != nil {
		return err
	}
	return json.NewEncoder(os.Stdout).Encode(report)
}

func runResetEmployeePasswords(ctx context.Context, db *pgxpool.Pool, cfg config.Config, args []string) error {
	apply, err := applyFlag("reset_employee_passwords", args)
	if err != nil {
		return err
	}
	if !apply {
		report, err := provision.PreviewReset(ctx, db)
		if err != nil {
			return err
		}
		return json.NewEncoder(os.Stdout).Encode(report)
	}
	password, err := initialPassword()
	if err != nil {
		return err
	}
	hash, err := security.HashPassword(password, cfg.BcryptCost)
	password = ""
	if err != nil {
		return fmt.Errorf("new employee password does not meet policy: %w", err)
	}
	report, err := provision.ResetActive(ctx, db, hash)
	if err != nil {
		return err
	}
	return json.NewEncoder(os.Stdout).Encode(report)
}

func initialPassword() (string, error) {
	if password := os.Getenv("INITIAL_EMPLOYEE_PASSWORD"); password != "" {
		return password, nil
	}
	tty, err := os.OpenFile("/dev/tty", os.O_RDWR, 0)
	if err != nil {
		return "", errors.New("INITIAL_EMPLOYEE_PASSWORD is required when no interactive TTY is available")
	}
	defer tty.Close()
	if !term.IsTerminal(int(tty.Fd())) {
		return "", errors.New("INITIAL_EMPLOYEE_PASSWORD is required when no interactive TTY is available")
	}
	if _, err := fmt.Fprint(tty, "Initial employee password: "); err != nil {
		return "", err
	}
	first, err := term.ReadPassword(int(tty.Fd()))
	if _, writeErr := fmt.Fprintln(tty); err != nil {
		return "", err
	} else if writeErr != nil {
		return "", writeErr
	}
	if _, err := fmt.Fprint(tty, "Confirm initial employee password: "); err != nil {
		return "", err
	}
	second, err := term.ReadPassword(int(tty.Fd()))
	_, _ = fmt.Fprintln(tty)
	if err != nil {
		return "", err
	}
	if string(first) != string(second) {
		return "", errors.New("password confirmation does not match")
	}
	if strings.TrimSpace(string(first)) == "" {
		return "", errors.New("initial password must not be empty")
	}
	return string(first), nil
}
