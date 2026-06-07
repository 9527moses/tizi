#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
STATUS_BOARD_FILE="$ROOT_DIR/research/candidate-status-board.md"
GUIDE_FILE="$ROOT_DIR/docs/recommendations/airport-guide-2026.md"
DAILY_DIR="$ROOT_DIR/research/daily"

TARGET_DATE=""
MAX_STALE_DAYS=3
STRICT=0

STATUS_ROWS_FILE=$(mktemp)
SYNC_ROWS_FILE=$(mktemp)

cleanup() {
  rm -f "$STATUS_ROWS_FILE" "$SYNC_ROWS_FILE"
}

trap cleanup EXIT

usage() {
  cat <<'EOF'
Usage: scripts/check-maintenance-health.sh [YYYY-MM-DD] [--max-stale-days N] [--strict]

Check whether daily notes, candidate status board, and public status overview
are staying in sync.
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

date_to_epoch() {
  source_date="$1"

  if date -j -f "%F" "$source_date" "+%s" >/dev/null 2>&1; then
    date -j -f "%F" "$source_date" "+%s"
  else
    date -d "$source_date" "+%s"
  fi
}

TARGET_EPOCH=$(date_to_epoch "$TARGET_DATE")
DAILY_NOTE_FILE="$DAILY_DIR/$TARGET_DATE.md"

ISSUE_COUNT=0
MISSING_DAILY=0
STALE_COUNT=0
PENDING_SYNC_COUNT=0
PENDING_PAGE_COUNT=0

printf '%s\n' "# 维护健康检查"
printf '\n'
printf '%s\n' "检查日期：$TARGET_DATE"
printf '%s\n' "过期提醒阈值：${MAX_STALE_DAYS} 天"
printf '\n'
printf '%s\n' "## 1. 日更记录"
printf '\n'

if [ -f "$DAILY_NOTE_FILE" ]; then
  printf '%s\n' "- 今日日更：已存在（$TARGET_DATE.md）"
else
  printf '%s\n' "- 今日日更：缺失，建议先运行 scripts/create-daily-check.sh $TARGET_DATE"
  MISSING_DAILY=1
  ISSUE_COUNT=$((ISSUE_COUNT + 1))
fi

printf '\n'
printf '%s\n' "## 2. 候选状态总表时效"
printf '\n'

awk -F'|' '
  /^\|/ {
    name = $2
    checked = $5
    status = $6

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", checked)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)

    if (name != "" && name != "名称" && name !~ /^-+$/) {
      printf("%s\t%s\t%s\n", name, checked, status)
    }
  }
' "$STATUS_BOARD_FILE" > "$STATUS_ROWS_FILE"

while IFS="$(printf '\t')" read -r name checked status; do
  [ -n "$name" ] || continue

  CHECKED_EPOCH=$(date_to_epoch "$checked")
  DIFF_DAYS=$(( (TARGET_EPOCH - CHECKED_EPOCH) / 86400 ))

  if [ "$DIFF_DAYS" -gt "$MAX_STALE_DAYS" ]; then
    printf '%s\n' "- ${name}：最近检查时间 ${checked}，当前状态 ${status}，已超过 ${MAX_STALE_DAYS} 天未复查"
    STALE_COUNT=$((STALE_COUNT + 1))
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  else
    printf '%s\n' "- ${name}：最近检查时间 ${checked}，当前状态 ${status}，时效正常"
  fi
done < "$STATUS_ROWS_FILE"

printf '\n'
printf '%s\n' "## 3. 总页联动同步状态"
printf '\n'

awk -F'|' '
  /<!-- STATUS_OVERVIEW:START -->/ {
    in_block = 1
    next
  }

  /<!-- STATUS_OVERVIEW:END -->/ {
    in_block = 0
    next
  }

  in_block == 1 && /^\|/ {
    name = $2
    sync_status = $7

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", sync_status)

    if (name != "" && name != "名称" && name !~ /^-+$/) {
      printf("%s\t%s\n", name, sync_status)
    }
  }
' "$GUIDE_FILE" > "$SYNC_ROWS_FILE"

SYNC_SECTION_EMPTY=1

while IFS="$(printf '\t')" read -r name sync_status; do
  [ -n "$name" ] || continue

  case "$sync_status" in
    "待同步")
      printf '%s\n' "- ${name}：${sync_status}"
      PENDING_SYNC_COUNT=$((PENDING_SYNC_COUNT + 1))
      ISSUE_COUNT=$((ISSUE_COUNT + 1))
      SYNC_SECTION_EMPTY=0
      ;;
    "待建页")
      printf '%s\n' "- ${name}：${sync_status}"
      PENDING_PAGE_COUNT=$((PENDING_PAGE_COUNT + 1))
      SYNC_SECTION_EMPTY=0
      ;;
  esac
done < "$SYNC_ROWS_FILE"

if [ "$SYNC_SECTION_EMPTY" -eq 1 ]; then
  printf '%s\n' "- 当前总页联动总览没有发现待同步项"
fi

printf '\n'
printf '%s\n' "## 4. 今日收口建议"
printf '\n'
printf '%s\n' "1. 先确认今日日更记录是否已建立并补完变化摘要。"
printf '%s\n' "2. 再核对 candidate-status-board.md 里相关候选的最近检查时间和状态。"
printf '%s\n' "3. 最后运行 scripts/sync-status-overview.sh，确认总页联动总览已经刷新。"

printf '\n'
printf '%s\n' "## 5. 当前结果"
printf '\n'
printf '%s\n' "- 缺失日更记录：${MISSING_DAILY}"
printf '%s\n' "- 超过阈值未复查：${STALE_COUNT}"
printf '%s\n' "- 总页待同步：${PENDING_SYNC_COUNT}"
printf '%s\n' "- 待建页提醒：${PENDING_PAGE_COUNT}"

if [ "$ISSUE_COUNT" -eq 0 ]; then
  printf '%s\n' "- 当前维护链路状态正常"
else
  printf '%s\n' "- 当前仍有 ${ISSUE_COUNT} 个需要处理的问题"
fi

if [ "$STRICT" -eq 1 ] && [ "$ISSUE_COUNT" -gt 0 ]; then
  exit 1
fi
