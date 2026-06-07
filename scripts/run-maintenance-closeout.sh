#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

TARGET_DATE=""
MAX_STALE_DAYS=""
STRICT=0

usage() {
  cat <<'EOF'
Usage: scripts/run-maintenance-closeout.sh [YYYY-MM-DD] [--max-stale-days N] [--strict]

Refresh the public status overview and then run the maintenance health check.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --max-stale-days)
      shift
      MAX_STALE_DAYS="$1"
      ;;
    --strict)
      STRICT=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [ -n "$TARGET_DATE" ]; then
        usage >&2
        exit 1
      fi
      TARGET_DATE="$1"
      ;;
  esac
  shift
done

if [ -z "$TARGET_DATE" ]; then
  TARGET_DATE=$(TZ=Asia/Shanghai date +%F)
fi

printf '%s\n' "Refreshing public status overview..."
"$ROOT_DIR/scripts/sync-status-overview.sh"

printf '\n'
printf '%s\n' "Refreshing maintenance dashboard..."
"$ROOT_DIR/scripts/update-maintenance-dashboard.sh" "$TARGET_DATE" ${MAX_STALE_DAYS:+--max-stale-days "$MAX_STALE_DAYS"}

printf '\n'
printf '%s\n' "Running maintenance health check..."

set -- "$TARGET_DATE"

if [ -n "$MAX_STALE_DAYS" ]; then
  set -- "$@" --max-stale-days "$MAX_STALE_DAYS"
fi

if [ "$STRICT" -eq 1 ]; then
  set -- "$@" --strict
fi

"$ROOT_DIR/scripts/check-maintenance-health.sh" "$@"
