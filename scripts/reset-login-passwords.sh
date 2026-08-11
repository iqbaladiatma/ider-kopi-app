#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../auth-backend"

EMPLOYEE_PASSWORD="iderkophebat"
ADMIN_PASSWORD="adminiderkophebat"

printf '\n==========================================\n'
printf ' Reset Initial Password IDER KOPI Mobile  \n'
printf '==========================================\n'
printf 'Password Karyawan : %s\n' "$EMPLOYEE_PASSWORD"
printf 'Password Admin    : %s\n' "$ADMIN_PASSWORD"
printf '------------------------------------------\n'

if [[ -d "$BACKEND_DIR" ]]; then
  cd "$BACKEND_DIR"
  printf '\n[1/1] Menjalankan reset_employee_passwords via Docker Compose...\n'
  docker compose run --rm \
    -e INITIAL_EMPLOYEE_PASSWORD="$EMPLOYEE_PASSWORD" \
    auth-api reset_employee_passwords --apply
  printf '\n[SUCCESS] Seluruh password awal karyawan telah di-reset ke: %s\n' "$EMPLOYEE_PASSWORD"
fi
