#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DASHBOARD_FILE="$ROOT_DIR/research/maintenance-dashboard.md"
SUMMARY_FILE="$ROOT_DIR/research/ops-today.md"
DAILY_DIR="$ROOT_DIR/research/daily"

TARGET_DATE=""
MAX_STALE_DAYS=3

usage() {
  cat <<'EOF'
Usage: scripts/update-ops-summary.sh [YYYY-MM-DD] [--max-stale-days N]

Refresh the short daily ops summary page from the maintenance dashboard.
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

extract_metric() {
  label="$1"

  awk -F'|' -v label="$label" '
    /^\|/ {
      left = $2
      right = $3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", left)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", right)

      if (left == label) {
        print right
        exit
      }
    }
  ' "$DASHBOARD_FILE"
}

DAILY_STATUS=$(extract_metric "今日日更记录")
STALE_COUNT=$(extract_metric "超过 ${MAX_STALE_DAYS} 天未复查")
PENDING_SYNC_COUNT=$(extract_metric "总页待同步项")
PENDING_PAGE_COUNT=$(extract_metric "待建页提醒")

CURRENT_STATE="正常"
CURRENT_ACTION="当前没有必须立刻处理的问题，按候补节奏继续补内容即可"

if [ "${DAILY_STATUS}" != "已存在" ]; then
  CURRENT_STATE="需要补日更"
  CURRENT_ACTION="先补当天的日更记录，再看后续内容更新。"
elif [ "${STALE_COUNT}" != "0" ]; then
  CURRENT_STATE="需要复查候选"
  CURRENT_ACTION="优先处理超过阈值未复查的候选，再决定是否更新公开页。"
elif [ "${PENDING_SYNC_COUNT}" != "0" ]; then
  CURRENT_STATE="需要同步总页"
  CURRENT_ACTION="详情页和状态总表可能已经变化，先刷新总页联动总览。"
elif [ "${PENDING_PAGE_COUNT}" != "0" ]; then
  CURRENT_STATE="可补候补详情页"
  CURRENT_ACTION="自动化链路正常，今天更适合继续补候补机场详情页。"
fi

DAILY_NOTE_LINK="daily/${TARGET_DATE}.md"
if [ ! -f "$DAILY_DIR/$TARGET_DATE.md" ]; then
  DAILY_NOTE_LINK="daily/README.md"
fi

{
  printf '%s\n' "# 今日维护摘要"
  printf '\n'
  printf '%s\n' "更新日期：$TARGET_DATE"
  printf '\n'
  printf '%s\n' "这页是自动刷新的简版运营摘要，用来在 10 秒内判断今天要不要人工介入。"
  printf '\n'
  printf '%s\n' "## 今日判断"
  printf '\n'
  printf '%s\n' "- 当前状态：${CURRENT_STATE}"
  printf '%s\n' "- 建议：${CURRENT_ACTION}"
  printf '\n'
  printf '%s\n' "## 关键数字"
  printf '\n'
  printf '%s\n' "| 项目 | 当前结果 |"
  printf '%s\n' "|---|---|"
  printf '%s\n' "| 今日日更记录 | ${DAILY_STATUS} |"
  printf '%s\n' "| 超过 ${MAX_STALE_DAYS} 天未复查 | ${STALE_COUNT} |"
  printf '%s\n' "| 总页待同步项 | ${PENDING_SYNC_COUNT} |"
  printf '%s\n' "| 待建页提醒 | ${PENDING_PAGE_COUNT} |"
  printf '\n'
  printf '%s\n' "## 今天优先做什么"
  printf '\n'
  printf '%s\n' "1. 如果你今天要补内容，优先补新的推荐页或候补详情页。"
  printf '%s\n' "2. 如果“超过 ${MAX_STALE_DAYS} 天未复查”不为 0，优先回查候选状态总表。"
  printf '%s\n' "3. 如果“总页待同步项”不为 0，优先刷新总页联动总览。"
  printf '%s\n' "4. 如果全部为 0，说明自动化链路正常，今天不需要专门救火。"
  printf '\n'
  printf '%s\n' "## 详细看板入口"
  printf '\n'
  printf '%s\n' "- [维护运营面板](maintenance-dashboard.md)"
  printf '%s\n' "- [今日检查记录](${DAILY_NOTE_LINK})"
  printf '%s\n' "- [候选状态总表](candidate-status-board.md)"
} > "$SUMMARY_FILE"

printf '%s\n' "Updated ops summary in $SUMMARY_FILE"
