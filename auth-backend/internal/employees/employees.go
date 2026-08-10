package employees

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/mail"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

const maxSourceBytes int64 = 4 << 20

type Employee struct {
	ExternalID      uuid.UUID
	EmployeeCode    string
	FullName        string
	Email           string
	Active          bool
	Brand           string
	Department      *string
	Position        *string
	SourceUpdatedAt *time.Time
}

type Source struct {
	URL    string
	Token  string
	Client *http.Client
}

func NewSource(url, token string) *Source {
	transport := &http.Transport{
		Proxy:           http.ProxyFromEnvironment,
		TLSClientConfig: &tls.Config{MinVersion: tls.VersionTLS12},
		MaxIdleConns:    10, IdleConnTimeout: 30 * time.Second,
		ResponseHeaderTimeout: 5 * time.Second,
	}
	return &Source{URL: url, Token: token, Client: &http.Client{
		Timeout: 10 * time.Second, Transport: transport,
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error { return errors.New("redirects are not allowed") },
	}}
}

func (s *Source) Fetch(ctx context.Context) ([]Employee, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, s.URL, nil)
	if err != nil {
		return nil, errors.New("create employee source request")
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("X-Mobile-Sync-Token", s.Token)
	resp, err := s.Client.Do(req)
	if err != nil {
		return nil, errors.New("employee source request failed")
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("employee source returned HTTP %d", resp.StatusCode)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, maxSourceBytes+1))
	if err != nil {
		return nil, errors.New("read employee source response")
	}
	if int64(len(body)) > maxSourceBytes {
		return nil, errors.New("employee source response exceeds size limit")
	}
	employees, err := ParseSource(body)
	if err != nil {
		return nil, errors.New("employee source returned invalid data")
	}
	return employees, nil
}

func ParseSource(body []byte) ([]Employee, error) {
	var items []json.RawMessage
	trimmed := bytes.TrimSpace(body)
	if len(trimmed) == 0 {
		return nil, errors.New("empty response")
	}
	if trimmed[0] == '[' {
		if err := json.Unmarshal(trimmed, &items); err != nil {
			return nil, err
		}
	} else {
		var wrapper struct {
			Data []json.RawMessage `json:"data"`
		}
		if err := json.Unmarshal(trimmed, &wrapper); err != nil {
			return nil, err
		}
		if wrapper.Data == nil {
			return nil, errors.New("missing data array")
		}
		items = wrapper.Data
	}
	result := make([]Employee, 0, len(items))
	for _, raw := range items {
		var v struct {
			ExternalID   string     `json:"external_id"`
			UUID         string     `json:"uuid"`
			ID           string     `json:"id"`
			EmployeeCode string     `json:"employee_code"`
			Name         string     `json:"name"`
			FullName     string     `json:"full_name"`
			Email        string     `json:"email"`
			Active       *bool      `json:"active"`
			IsActive     *bool      `json:"is_active"`
			Brand        string     `json:"brand"`
			Department   *string    `json:"department"`
			Position     *string    `json:"position"`
			UpdatedAt    *time.Time `json:"updated_at"`
		}
		if err := json.Unmarshal(raw, &v); err != nil {
			return nil, err
		}
		idText := first(v.ExternalID, v.UUID, v.ID)
		id, err := uuid.Parse(idText)
		if err != nil {
			return nil, errors.New("invalid external UUID")
		}
		email, err := normalizeEmail(v.Email)
		if err != nil {
			return nil, err
		}
		active := v.Active
		if active == nil {
			active = v.IsActive
		}
		if active == nil {
			return nil, errors.New("missing active status")
		}
		brand := strings.TrimSpace(v.Brand)
		if brand == "" || len(brand) > 100 {
			return nil, errors.New("invalid brand")
		}
		code := strings.TrimSpace(v.EmployeeCode)
		name := strings.TrimSpace(first(v.Name, v.FullName))
		if code == "" || name == "" {
			return nil, errors.New("missing employee code or name")
		}
		result = append(result, Employee{ExternalID: id, EmployeeCode: code, FullName: name, Email: email, Active: *active, Brand: brand, Department: trimOptional(v.Department), Position: trimOptional(v.Position), SourceUpdatedAt: v.UpdatedAt})
	}
	return result, nil
}

func trimOptional(value *string) *string {
	if value == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}
	return &trimmed
}

func first(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return strings.TrimSpace(value)
		}
	}
	return ""
}

func normalizeEmail(value string) (string, error) {
	v := strings.ToLower(strings.TrimSpace(value))
	parsed, err := mail.ParseAddress(v)
	if err != nil || parsed.Address != v || len(v) > 254 {
		return "", errors.New("invalid email")
	}
	return v, nil
}

type Conflict struct {
	Kind  string `json:"kind"`
	Brand string `json:"brand,omitempty"`
}

type Report struct {
	Input       int            `json:"input"`
	Created     int            `json:"created"`
	Updated     int            `json:"updated"`
	Unchanged   int            `json:"unchanged"`
	Deactivated int            `json:"deactivated"`
	Conflicts   []Conflict     `json:"conflicts"`
	Brands      map[string]int `json:"brands"`
	Applied     bool           `json:"applied"`
}

func Plan(current, incoming []Employee) Report {
	r := Report{Input: len(incoming), Brands: make(map[string]int), Conflicts: []Conflict{}}
	byID := make(map[uuid.UUID]Employee, len(current))
	currentEmail := make(map[string]uuid.UUID, len(current))
	seenID := make(map[uuid.UUID]struct{}, len(incoming))
	seenEmail := make(map[string]string, len(incoming))
	for _, employee := range current {
		byID[employee.ExternalID] = employee
		currentEmail[employee.Email] = employee.ExternalID
	}
	for _, employee := range incoming {
		r.Brands[employee.Brand]++
		if _, exists := seenID[employee.ExternalID]; exists {
			r.Conflicts = append(r.Conflicts, Conflict{Kind: "duplicate_external_uuid", Brand: employee.Brand})
			continue
		}
		seenID[employee.ExternalID] = struct{}{}
		if priorBrand, exists := seenEmail[employee.Email]; exists {
			r.Conflicts = append(r.Conflicts, Conflict{Kind: "duplicate_email", Brand: priorBrand})
			continue
		}
		seenEmail[employee.Email] = employee.Brand
		if owner, exists := currentEmail[employee.Email]; exists && owner != employee.ExternalID {
			r.Conflicts = append(r.Conflicts, Conflict{Kind: "email_owned_by_another_employee", Brand: employee.Brand})
			continue
		}
		old, exists := byID[employee.ExternalID]
		if !exists {
			r.Created++
			continue
		}
		if old.EmployeeCode != employee.EmployeeCode || old.FullName != employee.FullName || old.Email != employee.Email || old.Active != employee.Active || old.Brand != employee.Brand || !sameOptional(old.Department, employee.Department) || !sameOptional(old.Position, employee.Position) || !sameTime(old.SourceUpdatedAt, employee.SourceUpdatedAt) {
			r.Updated++
		} else {
			r.Unchanged++
		}
	}
	for id, employee := range byID {
		if _, exists := seenID[id]; !exists && employee.Active {
			r.Deactivated++
		}
	}
	return r
}

func sameTime(a, b *time.Time) bool {
	if a == nil || b == nil {
		return a == nil && b == nil
	}
	return a.Equal(*b)
}

func sameOptional(a, b *string) bool {
	if a == nil || b == nil {
		return a == nil && b == nil
	}
	return *a == *b
}

func LoadCurrent(ctx context.Context, db *pgxpool.Pool) ([]Employee, error) {
	rows, err := db.Query(ctx, `SELECT external_id, employee_code, full_name, email, active, brand, department, position, source_updated_at FROM employees`)
	if err != nil {
		return nil, fmt.Errorf("load employee snapshot: %w", err)
	}
	defer rows.Close()
	var result []Employee
	for rows.Next() {
		var employee Employee
		if err := rows.Scan(&employee.ExternalID, &employee.EmployeeCode, &employee.FullName, &employee.Email, &employee.Active, &employee.Brand, &employee.Department, &employee.Position, &employee.SourceUpdatedAt); err != nil {
			return nil, err
		}
		result = append(result, employee)
	}
	return result, rows.Err()
}

func Apply(ctx context.Context, db *pgxpool.Pool, incoming []Employee) error {
	tx, err := db.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return fmt.Errorf("begin employee sync: %w", err)
	}
	defer tx.Rollback(ctx)
	ids := make([]uuid.UUID, 0, len(incoming))
	for _, employee := range incoming {
		ids = append(ids, employee.ExternalID)
		_, err = tx.Exec(ctx, `
			INSERT INTO employees(external_id,employee_code,full_name,email,active,brand,department,position,source_updated_at,synced_at)
			VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,now())
			ON CONFLICT(external_id) DO UPDATE SET
			  employee_code=excluded.employee_code, full_name=excluded.full_name,
			  email=excluded.email, active=excluded.active, brand=excluded.brand,
			  department=excluded.department, position=excluded.position,
			  source_updated_at=excluded.source_updated_at, synced_at=now()`,
			employee.ExternalID, employee.EmployeeCode, employee.FullName, employee.Email, employee.Active, employee.Brand, employee.Department, employee.Position, employee.SourceUpdatedAt)
		if err != nil {
			return fmt.Errorf("write employee snapshot: %w", err)
		}
	}
	if len(ids) == 0 {
		_, err = tx.Exec(ctx, `UPDATE employees SET active=false, synced_at=now() WHERE active=true`)
	} else {
		_, err = tx.Exec(ctx, `UPDATE employees SET active=false, synced_at=now() WHERE active=true AND NOT (external_id = ANY($1::uuid[]))`, ids)
	}
	if err != nil {
		return fmt.Errorf("deactivate missing employees: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit employee sync: %w", err)
	}
	return nil
}
