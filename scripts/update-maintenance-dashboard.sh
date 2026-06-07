#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
STATUS_BOARD_FILE="$ROOT_DIR/research/candidate-status-board.md"
GUIDE_FILE="$ROOT_DIR/docs/recommendations/airport-guide-2026.md"
DASHBOARD_FILE="$ROOT_DIR/research/maintenance-dashboard.md"
DAILY_DIR="$ROOT_DIR/research/daily"

TARGET_DATE=""
MAX_STALE_DAYS=3

STATUS_ROWS_FILE=$(mktemp)
STALE_ROWS_FILE=$(mktemp)
SYNC_ROWS_FILE=$(mktemp)
PENDING_PAGE_ROWS_FILE=$(mktemp)

cleanup() {
  rm -f "$STATUS_ROWS_FILE" "$STALE_ROWS_FILE" "$SYNC_ROWS_FILE" "$PENDING_PAGE_ROWS_FILE"
}

trap cleanup EXIT

usage() {
  cat <<'EOF'
Usage: scripts/update-maintenance-dashboard.sh [YYYY-MM-DD] [--max-stale-days N]

Refresh the fixed Markdown maintenance dashboard.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --max-stale-days)
      shift
      MAX_STALE_DAYS="$1"
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

DAILY_STATUS="缺失"
if [ -f "$DAILY_NOTE_FILE" ]; then
  DAILY_STATUS="已存在"
fi

TOTAL_CANDIDATES=0
STALE_COUNT=0
PENDING_SYNC_COUNT=0
PENDING_PAGE_COUNT=0

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

  TOTAL_CANDIDATES=$((TOTAL_CANDIDATES + 1))
  CHECKED_EPOCH=$(date_to_epoch "$checked")
  DIFF_DAYS=$(( (TARGET_EPOCH - CHECKED_EPOCH) / 86400 ))

  if [ "$DIFF_DAYS" -gt "$MAX_STALE_DAYS" ]; then
    printf '%s\t%s\t%s\t%s\n' "$name" "$checked" "$status" "$DIFF_DAYS" >> "$STALE_ROWS_FILE"
  fi
done < "$STATUS_ROWS_FILE"

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
      if (sync_status == "待同步") {
        printf("%s\t%s\n", name, sync_status)
      } else if (sync_status == "待建页") {
        printf("%s\t%s\n", name, sync_status)
      }
    }
  }
' "$GUIDE_FILE" | while IFS="$(printf '\t')" read -r name sync_status; do
  [ -n "$name" ] || continue

  if [ "$sync_status" = "待同步" ]; then
    printf '%s\t%s\n' "$name" "$sync_status" >> "$SYNC_ROWS_FILE"
  elif [ "$sync_status" = "待建页" ]; then
    printf '%s\t%s\n' "$name" "$sync_status" >> "$PENDING_PAGE_ROWS_FILE"
  fi
done

if [ -f "$STALE_ROWS_FILE" ]; then
  STALE_COUNT=$(wc -l < "$STALE_ROWS_FILE" | tr -d ' ')
fi

if [ -f "$SYNC_ROWS_FILE" ]; then
  PENDING_SYNC_COUNT=$(wc -l < "$SYNC_ROWS_FILE" | tr -d ' ')
fi

if [ -f "$PENDING_PAGE_ROWS_FILE" ]; then
  PENDING_PAGE_COUNT=$(wc -l < "$PENDING_PAGE_ROWS_FILE" | tr -d ' ')
fi

{
  printf '%s\n' "# 维护运营面板"
  printf '\n'
  printf '%s\n' "更新日期：$TARGET_DATE"
  printf '\n'
  printf '%s\n' "这页是自动刷新的内部运营看板，用来快速判断维护链路当前是否健康。"
  printf '\n'
  printf '%s\n' "## 今日概览"
  printf '\n'
  printf '%s\n' "| 项目 | 当前结果 |"
  printf '%s\n' "|---|---|"
  printf '%s\n' "| 今日日更记录 | ${DAILY_STATUS} |"
  printf '%s\n' "| 候选总数 | ${TOTAL_CANDIDATES} |"
  printf '%s\n' "| 超过 ${MAX_STALE_DAYS} 天未复查 | ${STALE_COUNT} |"
  printf '%s\n' "| 总页待同步项 | ${PENDING_SYNC_COUNT} |"
  printf '%s\n' "| 待建页提醒 | ${PENDING_PAGE_COUNT} |"
  printf '\n'

  printf '%s\n' "## 超过 ${MAX_STALE_DAYS} 天未复查候选"
  printf '\n'
  if [ "$STALE_COUNT" -eq 0 ]; then
    printf '%s\n' "- 当前没有超过阈值未复查的候选"
  else
    printf '%s\n' "| 名称 | 最近检查时间 | 当前状态 | 已间隔天数 |"
    printf '%s\n' "|---|---|---|---|"
    while IFS="$(printf '\t')" read -r name checked status diff_days; do
      [ -n "$name" ] || continue
      printf '| %s | %s | %s | %s |\n' "$name" "$checked" "$status" "$diff_days"
    done < "$STALE_ROWS_FILE"
  fi
  printf '\n'

  printf '%s\n' "## 总页待同步项"
  printf '\n'
  if [ "$PENDING_SYNC_COUNT" -eq 0 ]; then
    printf '%s\n' "- 当前总页联动总览没有待同步项"
  else
    printf '%s\n' "| 名称 | 状态 |"
    printf '%s\n' "|---|---|"
    while IFS="$(printf '\t')" read -r name sync_status; do
      [ -n "$name" ] || continue
      printf '| %s | %s |\n' "$name" "$sync_status"
    done < "$SYNC_ROWS_FILE"
  fi
  printf '\n'

  printf '%s\n' "## 待建页提醒"
  printf '\n'
  if [ "$PENDING_PAGE_COUNT" -eq 0 ]; then
    printf '%s\n' "- 当前没有待建页提醒"
  else
    printf '%s\n' "| 名称 | 状态 |"
    printf '%s\n' "|---|---|"
    while IFS="$(printf '\t')" read -r name sync_status; do
      [ -n "$name" ] || continue
      printf '| %s | %s |\n' "$name" "$sync_status"
    done < "$PENDING_PAGE_ROWS_FILE"
  fi
  printf '\n'

  printf '%s\n' "## 建议动作"
  printf '\n'
  printf '%s\n' '1. 如果“今日日更记录”还是缺失，先补当天的 `research/daily/YYYY-MM-DD.md`。'
  printf '%s\n' "2. 如果“超过 ${MAX_STALE_DAYS} 天未复查”不为 0，优先回查候选状态总表。"
  printf '%s\n' '3. 如果“总页待同步项”不为 0，先运行 `scripts/sync-status-overview.sh` 或 `scripts/run-maintenance-closeout.sh`。'
  printf '%s\n' '4. 如果只剩 `待建页提醒`，说明链路本身正常，后续按候补节奏补详情页即可。'
} > "$DASHBOARD_FILE"

printf '%s\n' "Updated maintenance dashboard in $DASHBOARD_FILE"
