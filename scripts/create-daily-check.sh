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

date_to_epoch() {
  source_date="$1"

  if date -j -f "%F" "$source_date" "+%s" >/dev/null 2>&1; then
    date -j -f "%F" "$source_date" "+%s"
  else
    date -d "$source_date" "+%s"
  fi
}

TARGET_EPOCH=$(date_to_epoch "$TARGET_DATE")

CHECKLIST_FILE=$(mktemp)
PRIORITY_FILE=$(mktemp)
OUTPUT_FILE=$(mktemp)

cleanup() {
  if [ -n "${CHECKLIST_FILE:-}" ] && [ -f "$CHECKLIST_FILE" ]; then
    rm -f "$CHECKLIST_FILE"
  fi
  if [ -n "${PRIORITY_FILE:-}" ] && [ -f "$PRIORITY_FILE" ]; then
    rm -f "$PRIORITY_FILE"
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

awk -F'|' -v target_epoch="$TARGET_EPOCH" '
  function trim(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    return value
  }

  function route_priority(route) {
    if (route ~ /AI|ChatGPT/) return 1
    if (route ~ /高预算|商务办公|稳定办公|主力/) return 2
    if (route ~ /多设备|家宽|路由器/) return 3
    if (route ~ /低门槛|流媒体|观影/) return 4
    if (route ~ /备用|小流量/) return 5
    return 6
  }

  function date_to_epoch_local(source_date, command, result) {
    command = "date -j -f \"%F\" \"" source_date "\" \"+%s\" 2>/dev/null"
    command | getline result
    close(command)

    if (result != "") {
      return result + 0
    }

    command = "date -d \"" source_date "\" \"+%s\" 2>/dev/null"
    command | getline result
    close(command)

    return result + 0
  }

  /^\|/ {
    name = trim($2)
    level = trim($3)
    route = trim($4)
    checked = trim($5)
    status = trim($6)
    next_action = trim($7)

    if (name != "" && name != "名称" && name !~ /^-+$/) {
      route_score = route_priority(route)
      checked_epoch = date_to_epoch_local(checked)
      stale_days = int((target_epoch - checked_epoch) / 86400)
      if (stale_days < 0) {
        stale_days = 0
      }

      score = route_score * 100 - stale_days

      if (level == "正式位") {
        score += 50
      } else if (level == "首批观察位") {
        score += 10
      } else if (level == "第二批候补位") {
        score += 20
      }

      printf("%05d\t%s\t%s\t%s\t%s\t%s\t%s\n", score, name, route, status, checked, next_action, stale_days)
    }
  }
' "$STATUS_BOARD_FILE" | sort | awk -F'\t' '
  NR <= 3 {
    printf("- %s：%s；当前状态 %s；最近检查 %s；已间隔 %s 天；下一步 %s\n", $2, $3, $4, $5, $7, $6)
  }
' > "$PRIORITY_FILE"

if [ ! -s "$PRIORITY_FILE" ]; then
  printf '%s\n' "- 暂时没有可排序的重点候选，先检查候选状态总表是否完整" > "$PRIORITY_FILE"
fi

awk -v target_date="$TARGET_DATE" -v checklist_file="$CHECKLIST_FILE" -v priority_file="$PRIORITY_FILE" '
  {
    gsub(/YYYY-MM-DD/, target_date)
  }

  index($0, "{{PRIORITY_CANDIDATES}}") {
    while ((getline line < priority_file) > 0) {
      print line
    }
    close(priority_file)
    next
  }

  index($0, "{{CANDIDATE_CHECKLIST}}") {
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
