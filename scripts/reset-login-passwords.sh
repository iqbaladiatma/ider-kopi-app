#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.runtime/mobile-auth.env"

printf '\n==========================================\n'
printf ' Reset Password Karyawan IDER KOPI Mobile \n'
printf '==========================================\n'
printf '%s\n' '------------------------------------------'

if [[ ! -f "$PROJECT_ROOT/docker-compose.yml" ]]; then
  printf '[ERROR] docker-compose.yml tidak ditemukan di %s\n' "$PROJECT_ROOT" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  printf '[ERROR] Environment file tidak ditemukan: %s\n' "$ENV_FILE" >&2
  exit 1
fi

PASSWORD_CONFIGURED=false
while IFS='=' read -r KEY VALUE; do
  if [[ "$KEY" == "INITIAL_EMPLOYEE_PASSWORD" && -n "$VALUE" ]]; then
    PASSWORD_CONFIGURED=true
    break
  fi
done < "$ENV_FILE"

if [[ "$PASSWORD_CONFIGURED" != true ]]; then
  printf '[ERROR] INITIAL_EMPLOYEE_PASSWORD belum dikonfigurasi di %s\n' "$ENV_FILE" >&2
  exit 1
fi

cd "$PROJECT_ROOT"
docker compose --env-file "$ENV_FILE" config --quiet

printf '\n[PREVIEW] Akun karyawan yang memenuhi syarat reset:\n'
docker compose --env-file "$ENV_FILE" --profile tools run --rm \
  auth-provision reset_employee_passwords

printf '\nLanjutkan reset password seluruh karyawan aktif? [y/N] '
read -r CONFIRMATION
if [[ ! "$CONFIRMATION" =~ ^[Yy]$ ]]; then
  printf '[CANCELLED] Tidak ada password yang diubah.\n'
  exit 0
fi

printf '\nMenggunakan password yang tersimpan aman di runtime env.\n'
docker compose --env-file "$ENV_FILE" --profile tools run --rm \
  auth-password-reset
printf '\n[SUCCESS] Reset password karyawan selesai. Periksa laporan JSON di atas.\n'
