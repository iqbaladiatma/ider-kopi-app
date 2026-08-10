package provision

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ResetReport struct {
	Eligible      int  `json:"eligible"`
	Reset         int  `json:"reset"`
	TokensRevoked int  `json:"tokens_revoked"`
	Applied       bool `json:"applied"`
}

func PreviewReset(ctx context.Context, db *pgxpool.Pool) (ResetReport, error) {
	var report ResetReport
	if err := db.QueryRow(ctx, `
		SELECT count(*)
		FROM users u JOIN employees e ON e.external_id=u.employee_id
		WHERE u.active AND e.active`).Scan(&report.Eligible); err != nil {
		return report, fmt.Errorf("count reset candidates: %w", err)
	}
	return report, nil
}

func ResetActive(ctx context.Context, db *pgxpool.Pool, passwordHash string) (ResetReport, error) {
	tx, err := db.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return ResetReport{}, fmt.Errorf("begin employee password reset: %w", err)
	}
	defer tx.Rollback(ctx)

	var report ResetReport
	if err := tx.QueryRow(ctx, `
		SELECT count(*)
		FROM users u JOIN employees e ON e.external_id=u.employee_id
		WHERE u.active AND e.active`).Scan(&report.Eligible); err != nil {
		return report, fmt.Errorf("count reset candidates: %w", err)
	}
	command, err := tx.Exec(ctx, `
		UPDATE users u
		SET password_hash=$1, must_change_password=true, updated_at=now()
		FROM employees e
		WHERE e.external_id=u.employee_id AND u.active AND e.active`, passwordHash)
	if err != nil {
		return report, fmt.Errorf("reset employee passwords: %w", err)
	}
	report.Reset = int(command.RowsAffected())
	command, err = tx.Exec(ctx, `
		UPDATE refresh_tokens rt
		SET revoked_at=COALESCE(rt.revoked_at,now())
		FROM users u JOIN employees e ON e.external_id=u.employee_id
		WHERE rt.user_id=u.id AND u.active AND e.active AND rt.revoked_at IS NULL`)
	if err != nil {
		return report, fmt.Errorf("revoke employee sessions: %w", err)
	}
	report.TokensRevoked = int(command.RowsAffected())
	if report.Reset != report.Eligible {
		return report, fmt.Errorf("reset count mismatch: eligible=%d reset=%d", report.Eligible, report.Reset)
	}
	if err := tx.Commit(ctx); err != nil {
		return report, fmt.Errorf("commit employee password reset: %w", err)
	}
	report.Applied = true
	return report, nil
}
