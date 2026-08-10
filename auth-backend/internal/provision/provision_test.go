package provision

import (
	"testing"

	"github.com/google/uuid"
)

func TestPlanIsIdempotent(t *testing.T) {
	a, b := uuid.New(), uuid.New()
	candidates, report := Plan([]uuid.UUID{a, b}, []uuid.UUID{a})
	if len(candidates) != 1 || candidates[0].EmployeeID != b || report.Eligible != 1 || report.Existing != 1 {
		t.Fatalf("unexpected plan: %+v %+v", candidates, report)
	}
	candidates, report = Plan([]uuid.UUID{a, b}, []uuid.UUID{a, b})
	if len(candidates) != 0 || report.Eligible != 0 {
		t.Fatalf("second plan not idempotent: %+v", report)
	}
}
