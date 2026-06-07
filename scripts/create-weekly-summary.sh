#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMPLATE_FILE="$ROOT_DIR/research/templates/weekly-summary-template.md"
TARGET_DIR="$ROOT_DIR/research/weekly"
DAILY_DIR="$ROOT_DIR/research/daily"

ANCHOR_DATE=""
FORCE=0
TO_STDOUT=0

usage() {
  cat <<'EOF'
Usage: scripts/create-weekly-summary.sh [YYYY-MM-DD] [--force] [--stdout]

Create a weekly summary note from the research template.

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
      if [ -n "$ANCHOR_DATE" ]; then
        usage >&2
        exit 1
      fi
      ANCHOR_DATE="$1"
      ;;
  esac
  shift
done

format_date() {
  source_date="$1"
  format_string="$2"

  if [ -n "$source_date" ]; then
    if date -j -f "%F" "$source_date" "+$format_string" >/dev/null 2>&1; then
      date -j -f "%F" "$source_date" "+$format_string"
    else
      date -d "$source_date" "+$format_string"
    fi
  else
    date "+$format_string"
  fi
}

shift_date() {
  source_date="$1"
  delta_days="$2"

  if date -j -f "%F" "$source_date" "+%F" >/dev/null 2>&1; then
    if [ "$delta_days" -eq 0 ]; then
      date -j -f "%F" "$source_date" "+%F"
    elif [ "$delta_days" -gt 0 ]; then
      date -j -v+"${delta_days}"d -f "%F" "$source_date" "+%F"
    else
      positive_days=$((0 - delta_days))
      date -j -v-"${positive_days}"d -f "%F" "$source_date" "+%F"
    fi
  else
    if [ "$delta_days" -eq 0 ]; then
      date -d "$source_date" "+%F"
    else
      date -d "$source_date ${delta_days} day" "+%F"
    fi
  fi
}

if [ -z "$ANCHOR_DATE" ]; then
  ANCHOR_DATE=$(TZ=Asia/Shanghai date +%F)
fi

WEEK_LABEL=$(format_date "$ANCHOR_DATE" "%G-W%V")
WEEKDAY=$(format_date "$ANCHOR_DATE" "%u")
WEEK_START=$(shift_date "$ANCHOR_DATE" "$((1 - WEEKDAY))")
WEEK_END=$(shift_date "$ANCHOR_DATE" "$((7 - WEEKDAY))")

DAILY_INDEX_FILE=$(mktemp)
OUTPUT_FILE=$(mktemp)

cleanup() {
  if [ -n "${DAILY_INDEX_FILE:-}" ] && [ -f "$DAILY_INDEX_FILE" ]; then
    rm -f "$DAILY_INDEX_FILE"
  fi
  if [ -n "${OUTPUT_FILE:-}" ] && [ -f "$OUTPUT_FILE" ]; then
    rm -f "$OUTPUT_FILE"
  fi
}

trap cleanup EXIT

current_date="$WEEK_START"

while :; do
  relative_path="../daily/${current_date}.md"
  absolute_path="$DAILY_DIR/${current_date}.md"

  if [ -f "$absolute_path" ]; then
    printf '%s\n' "- [x] [${current_date}](${relative_path})" >> "$DAILY_INDEX_FILE"
  else
    printf '%s\n' "- [ ] ${current_date}" >> "$DAILY_INDEX_FILE"
  fi

  if [ "$current_date" = "$WEEK_END" ]; then
    break
  fi

  current_date=$(shift_date "$current_date" 1)
done

awk \
  -v week_label="$WEEK_LABEL" \
  -v week_start="$WEEK_START" \
  -v week_end="$WEEK_END" \
  -v summary_date="$ANCHOR_DATE" \
  -v daily_index_file="$DAILY_INDEX_FILE" '
  {
    gsub(/\{\{WEEK_LABEL\}\}/, week_label)
    gsub(/\{\{WEEK_START\}\}/, week_start)
    gsub(/\{\{WEEK_END\}\}/, week_end)
    gsub(/\{\{SUMMARY_DATE\}\}/, summary_date)
  }

  index($0, "{{DAILY_NOTE_INDEX}}") {
    while ((getline line < daily_index_file) > 0) {
      print line
    }
    close(daily_index_file)
    next
  }

  { print }
' "$TEMPLATE_FILE" > "$OUTPUT_FILE"

if [ "$TO_STDOUT" -eq 1 ]; then
  cat "$OUTPUT_FILE"
  exit 0
fi

mkdir -p "$TARGET_DIR"
TARGET_FILE="$TARGET_DIR/$WEEK_LABEL.md"

if [ -f "$TARGET_FILE" ] && [ "$FORCE" -ne 1 ]; then
  printf '%s\n' "Weekly summary already exists: $TARGET_FILE"
  exit 0
fi

mv "$OUTPUT_FILE" "$TARGET_FILE"
OUTPUT_FILE=""

printf '%s\n' "Created $TARGET_FILE"
