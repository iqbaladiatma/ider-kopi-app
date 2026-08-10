#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="/Users/ainud/Projects/ider-kopi-app"
CORE_ROOT="/Users/ainud/Projects/ider-kopi"
AUTH_ENV="$APP_ROOT/.runtime/mobile-auth.env"
SUPER_ADMIN_EMAIL="admin@iderkopi.com"

if [[ ! -f "$AUTH_ENV" ]]; then
  printf 'Error: runtime auth environment tidak ditemukan: %s\n' "$AUTH_ENV" >&2
  exit 1
fi

command -v docker >/dev/null 2>&1 || {
  printf 'Error: docker tidak tersedia di PATH.\n' >&2
  exit 1
}

printf '\n[1/2] Reset password awal untuk seluruh employee aktif...\n'
printf 'Password akan diminta dua kali dan tidak ditampilkan.\n\n'
cd "$APP_ROOT"
docker compose \
  --env-file "$AUTH_ENV" \
  --profile tools \
  run --rm -it \
  auth-provision \
  reset_employee_passwords --apply

printf '\n[2/2] Reset password super_admin %s...\n' "$SUPER_ADMIN_EMAIL"
printf 'Password akan diminta dua kali dan tidak ditampilkan.\n\n'
cd "$CORE_ROOT"
docker compose run --rm -it \
  -e "RESET_ADMIN_EMAIL=$SUPER_ADMIN_EMAIL" \
  --entrypoint /usr/local/bin/reset_admin_password \
  backend

printf '\nSelesai: password employee dan super_admin berhasil di-reset.\n'
printf 'Employee tetap wajib mengganti password saat login pertama.\n'
