#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMPLATE_FILE="$ROOT_DIR/research/templates/daily-check-template.md"
STATUS_BOARD_FILE="$ROOT_DIR/research/candidate-status-board.md"
TARGET_DIR="$ROOT_DIR/research/daily"

TARGET_DATE=""
FORCE=0
TO_STDOUT=0

usage() {
  cat <<'EOF'
Usage: scripts/create-daily-check.sh [YYYY-MM-DD] [--force] [--stdout]

Create a daily maintenance note from the research template.

Options:
  --force   Overwrite the target file if it already exists
  --stdout  Print the generated note instead of writing a file
  --help    Show this help message
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --force)
      FORCE=1
      ;;
    --stdout)
      TO_STDOUT=1
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

CHECKLIST_FILE=$(mktemp)
OUTPUT_FILE=$(mktemp)

cleanup() {
  if [ -n "${CHECKLIST_FILE:-}" ] && [ -f "$CHECKLIST_FILE" ]; then
    rm -f "$CHECKLIST_FILE"
  fi
  if [ -n "${OUTPUT_FILE:-}" ] && [ -f "$OUTPUT_FILE" ]; then
    rm -f "$OUTPUT_FILE"
  fi
}

trap cleanup EXIT

awk -F'|' '
  /^\|/ {
    name = $2
    status = $6
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)

    if (name != "" && name != "名称" && name !~ /^-+$/) {
      printf("- [ ] %s（%s）\n", name, status)
    }
  }
' "$STATUS_BOARD_FILE" > "$CHECKLIST_FILE"

if [ ! -s "$CHECKLIST_FILE" ]; then
  printf '%s\n' "- [ ] 暂无候选，先补候选状态总表" > "$CHECKLIST_FILE"
fi

awk -v target_date="$TARGET_DATE" -v checklist_file="$CHECKLIST_FILE" '
  {
    gsub(/YYYY-MM-DD/, target_date)
  }

  /{{CANDIDATE_CHECKLIST}}/ {
    while ((getline line < checklist_file) > 0) {
      print line
    }
    close(checklist_file)
    next
  }

  { print }
' "$TEMPLATE_FILE" > "$OUTPUT_FILE"

if [ "$TO_STDOUT" -eq 1 ]; then
  cat "$OUTPUT_FILE"
  exit 0
fi

mkdir -p "$TARGET_DIR"
TARGET_FILE="$TARGET_DIR/$TARGET_DATE.md"

if [ -f "$TARGET_FILE" ] && [ "$FORCE" -ne 1 ]; then
  printf '%s\n' "Daily note already exists: $TARGET_FILE"
  exit 0
fi

mv "$OUTPUT_FILE" "$TARGET_FILE"
OUTPUT_FILE=""

printf '%s\n' "Created $TARGET_FILE"
