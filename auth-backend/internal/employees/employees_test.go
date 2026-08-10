package employees

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestParseSourceArrayAndWrapper(t *testing.T) {
	id := uuid.New().String()
	for _, body := range []string{
		`[{"external_id":"` + id + `","employee_code":"EMP-1","name":"Ayu Kopi","email":" User@Example.Test ","active":true,"brand":"Ider Kopi","department":"Store","position":"Barista"}]`,
		`{"data":[{"uuid":"` + id + `","employee_code":"EMP-1","full_name":"Ayu Kopi","email":"User@Example.Test","is_active":true,"brand":"Ider Kopi","department":"Store","position":"Barista"}]}`,
	} {
		items, err := ParseSource([]byte(body))
		if err != nil {
			t.Fatal(err)
		}
		if len(items) != 1 || items[0].Email != "user@example.test" || items[0].EmployeeCode != "EMP-1" || items[0].FullName != "Ayu Kopi" {
			t.Fatalf("unexpected parse: %+v", items)
		}
	}
}

func TestSourceHeaderAndSafeError(t *testing.T) {
	var token string
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		token = r.Header.Get("X-Mobile-Sync-Token")
		return &http.Response{StatusCode: http.StatusBadGateway, Body: io.NopCloser(strings.NewReader("secret upstream detail")), Header: make(http.Header)}, nil
	})}
	source := &Source{URL: "https://employees.example.test", Token: "sync-secret", Client: client}
	_, err := source.Fetch(context.Background())
	if token != "sync-secret" {
		t.Fatal("sync token header missing")
	}
	if err == nil || strings.Contains(err.Error(), "secret upstream detail") {
		t.Fatalf("unsafe error: %v", err)
	}
}

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func TestPlanDetectsChangesAndConflicts(t *testing.T) {
	id1, id2 := uuid.New(), uuid.New()
	current := []Employee{{ExternalID: id1, Email: "one@example.test", Active: true, Brand: "A"}}
	incoming := []Employee{
		{ExternalID: id1, Email: "one@example.test", Active: false, Brand: "A"},
		{ExternalID: id2, Email: "one@example.test", Active: true, Brand: "B"},
	}
	r := Plan(current, incoming)
	if r.Updated != 1 || len(r.Conflicts) != 1 || r.Conflicts[0].Kind != "duplicate_email" {
		t.Fatalf("unexpected plan: %+v", r)
	}
}
