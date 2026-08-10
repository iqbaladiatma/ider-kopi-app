package provision

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Candidate struct{ EmployeeID uuid.UUID }

type Report struct {
	Eligible int  `json:"eligible"`
	Existing int  `json:"existing"`
	Created  int  `json:"created"`
	Applied  bool `json:"applied"`
}

func Plan(activeEmployeeIDs, existingEmployeeIDs []uuid.UUID) ([]Candidate, Report) {
	existing := make(map[uuid.UUID]struct{}, len(existingEmployeeIDs))
	for _, id := range existingEmployeeIDs {
		existing[id] = struct{}{}
	}
	report := Report{Existing: len(existingEmployeeIDs)}
	var candidates []Candidate
	for _, id := range activeEmployeeIDs {
		if _, ok := existing[id]; ok {
			continue
		}
		candidates = append(candidates, Candidate{EmployeeID: id})
	}
	report.Eligible = len(candidates)
	return candidates, report
}

func Preview(ctx context.Context, db *pgxpool.Pool) (Report, error) {
	var report Report
	if err := db.QueryRow(ctx, `SELECT count(*) FROM users`).Scan(&report.Existing); err != nil {
		return report, fmt.Errorf("count existing accounts: %w", err)
	}
	if err := db.QueryRow(ctx, `SELECT count(*) FROM employees e WHERE e.active AND NOT EXISTS (SELECT 1 FROM users u WHERE u.employee_id=e.external_id)`).Scan(&report.Eligible); err != nil {
		return report, fmt.Errorf("count eligible accounts: %w", err)
	}
	return report, nil
}

func Apply(ctx context.Context, db *pgxpool.Pool, passwordHash string) (Report, error) {
	tx, err := db.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return Report{}, fmt.Errorf("begin account provisioning: %w", err)
	}
	defer tx.Rollback(ctx)
	var report Report
	if err := tx.QueryRow(ctx, `SELECT count(*) FROM users`).Scan(&report.Existing); err != nil {
		return report, err
	}
	command, err := tx.Exec(ctx, `
		INSERT INTO users(id, employee_id, role_id, password_hash, must_change_password, active)
		SELECT gen_random_uuid(), e.external_id, r.id, $1, true, true
		FROM employees e CROSS JOIN roles r
		WHERE e.active AND r.name='employee'
		  AND NOT EXISTS (SELECT 1 FROM users u WHERE u.employee_id=e.external_id)
		ON CONFLICT(employee_id) DO NOTHING`, passwordHash)
	if err != nil {
		return report, fmt.Errorf("create employee accounts: %w", err)
	}
	report.Created = int(command.RowsAffected())
	report.Eligible = report.Created
	report.Applied = true
	if err := tx.Commit(ctx); err != nil {
		return report, fmt.Errorf("commit account provisioning: %w", err)
	}
	return report, nil
}
