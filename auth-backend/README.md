# Ider Kopi mobile authentication backend

This directory is a self-contained Go/Fiber authentication service for the mobile application. It owns a dedicated PostgreSQL database; it does not read from or join against another database. Employee records arrive only through the configured HTTPS employee source.

## Security model

- Access tokens are HS256 JWTs with issuer `iderkopi-mobile-auth`. They contain `sub` (the user UUID), `employee_id` (the source UUID), normalized `email`, role `employee`, and `must_change_password`.
- Refresh tokens contain 256 random bits and are stored only as SHA-256 hashes. Refresh rotates them transactionally. Logout revokes the supplied token; a password change revokes every refresh token for the user.
- Provisioned accounts must change their password. Until they do, protected business endpoints such as `/me` return HTTP 403; logout and password change remain available.
- Passwords use bcrypt with a required cost from 10 through 15. Passwords must be 12 or more characters (and at most bcrypt's 72-byte limit), with uppercase, lowercase, number, and symbol, and no whitespace.
- Login and refresh are rate-limited. The server also sets defensive headers, limits request bodies, uses finite server and upstream timeouts, and returns generic authentication/source errors.

## Configuration

Copy values from `.env.example` into a local root `.env` and replace every placeholder. Do not commit that file. All settings needed by a command are required; startup fails closed when one is absent or invalid. Generate the JWT secret from a cryptographically secure source and use at least 32 characters.

The Compose database URL uses `sslmode=disable` only on the private Docker network. When running the binary against any database outside that network, provide a TLS-enabled `MOBILE_AUTH_DATABASE_URL`.

## Runbook

Validate the Compose model before starting anything:

```sh
docker compose config --quiet
```

Start the dedicated database, one-shot embedded migration runner, and API:

```sh
docker compose up -d auth-db auth-migrations auth-api
curl --fail http://127.0.0.1:2027/health
```

The database has no published host port. Its data is retained in the named volume `iderkopi_mobile_auth_data`.

Employee synchronization is a dry run unless `--apply` is present. The source must return either a JSON array or `{ "data": [...] }`. Each item needs an external UUID (`external_id`, `uuid`, or `id`), email, boolean `active`/`is_active`, and brand. A successful snapshot upserts by external UUID and deactivates active employees missing from the snapshot. Output is limited to aggregate counts, conflict types, and brand counts.

```sh
docker compose run --rm \
  -e EMPLOYEE_SOURCE_URL="$EMPLOYEE_SOURCE_URL" \
  -e EMPLOYEE_SOURCE_TOKEN="$EMPLOYEE_SOURCE_TOKEN" \
  auth-api sync_employees

# Review the report, then explicitly apply the same source snapshot:
docker compose run --rm \
  -e EMPLOYEE_SOURCE_URL="$EMPLOYEE_SOURCE_URL" \
  -e EMPLOYEE_SOURCE_TOKEN="$EMPLOYEE_SOURCE_TOKEN" \
  auth-api sync_employees --apply
```

Account provisioning is also dry-run-first and creates accounts only for active employees without one. Existing accounts and passwords are never reset. For non-interactive Compose use, inject the initial password for the single command; it is not printed or included in the report. Every newly provisioned account receives that temporary password and is forced to change it.

```sh
docker compose run --rm auth-api provision_accounts
docker compose run --rm \
  -e INITIAL_EMPLOYEE_PASSWORD="$INITIAL_EMPLOYEE_PASSWORD" \
  auth-api provision_accounts --apply
```

When running the binary directly in an interactive terminal, omit `INITIAL_EMPLOYEE_PASSWORD`; `--apply` prompts twice using hidden TTY input.

## API

All request and response bodies are JSON except successful logout and password change, which return HTTP 204.

| Method | Path | Authentication | Purpose |
| --- | --- | --- | --- |
| GET | `/health` | none | database-backed health check |
| POST | `/api/v1/auth/login` | none | email/password login |
| POST | `/api/v1/auth/refresh` | refresh token body | rotate session tokens |
| POST | `/api/v1/auth/logout` | bearer + refresh token body | revoke refresh token |
| GET | `/api/v1/auth/me` | bearer; password changed | current identity |
| POST | `/api/v1/auth/change-password` | bearer | replace password and revoke all refresh tokens |

Login accepts `email` and `password`. Refresh/logout accept `refresh_token`. Password change accepts `current_password` and `new_password`. After password change, authenticate again because all refresh sessions are revoked and the old access token's claim remains stale until it expires.

## Local verification

```sh
go fmt ./...
go mod tidy
go test ./...
go vet ./...
```

Migrations are ordinary SQL files in `migrations/` and are embedded into the same binary. The runner serializes concurrent attempts with a PostgreSQL advisory lock and records each applied filename in `schema_migrations`.
