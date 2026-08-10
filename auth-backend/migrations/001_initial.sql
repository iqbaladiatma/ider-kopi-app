CREATE TABLE roles (
    id SMALLSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT roles_name_normalized CHECK (name = lower(btrim(name)) AND name <> '')
);

INSERT INTO roles (name) VALUES ('employee') ON CONFLICT (name) DO NOTHING;

CREATE TABLE employees (
    external_id UUID PRIMARY KEY,
    employee_code TEXT NOT NULL,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    active BOOLEAN NOT NULL,
    brand TEXT NOT NULL,
    department TEXT,
    position TEXT,
    source_updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT employees_email_normalized CHECK (email = lower(btrim(email)) AND email <> ''),
    CONSTRAINT employees_code_nonempty CHECK (btrim(employee_code) <> ''),
    CONSTRAINT employees_name_nonempty CHECK (btrim(full_name) <> ''),
    CONSTRAINT employees_brand_nonempty CHECK (btrim(brand) <> '')
);

CREATE UNIQUE INDEX employees_email_unique ON employees (email);

CREATE TABLE users (
    id UUID PRIMARY KEY,
    employee_id UUID NOT NULL UNIQUE REFERENCES employees(external_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    role_id SMALLINT NOT NULL REFERENCES roles(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    password_hash TEXT NOT NULL,
    must_change_password BOOLEAN NOT NULL DEFAULT TRUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash BYTEA NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    replaced_by UUID REFERENCES refresh_tokens(id) ON DELETE SET NULL
);

CREATE INDEX refresh_tokens_user_active_idx ON refresh_tokens (user_id, expires_at)
    WHERE revoked_at IS NULL;
