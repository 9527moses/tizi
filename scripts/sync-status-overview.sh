#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
STATUS_BOARD_FILE="$ROOT_DIR/research/candidate-status-board.md"
GUIDE_FILE="$ROOT_DIR/docs/recommendations/airport-guide-2026.md"
TMP_DATA_FILE=$(mktemp)
TMP_BLOCK_FILE=$(mktemp)
TMP_OUTPUT_FILE=$(mktemp)

cleanup() {
  rm -f "$TMP_DATA_FILE" "$TMP_BLOCK_FILE" "$TMP_OUTPUT_FILE"
}

trap cleanup EXIT

level_label() {
  case "$1" in
    "正式位")
      printf '%s' "第一级：正式位"
      ;;
    "首批观察位")
      printf '%s' "第二级：首批重点观察位"
      ;;
    "第二批候补位")
      printf '%s' "第三级：第二批候补池"
      ;;
    *)
      printf '%s' "$1"
      ;;
  esac
}

detail_path_for_name() {
  case "$1" in
    "Roxi")
      printf '%s' "roxi-review.md"
      ;;
    "SSOne")
      printf '%s' "ssone-observation.md"
      ;;
    "隐云")
      printf '%s' "yinyun-observation.md"
      ;;
    "闪狐云")
      printf '%s' "flashfox-observation.md"
      ;;
    "奈云")
      printf '%s' "nayun-observation.md"
      ;;
    "XXYUN")
      printf '%s' "xxyun-observation.md"
      ;;
    "flybit")
      printf '%s' "flybit-observation.md"
      ;;
    "WgetCloud")
      printf '%s' "wgetcloud-observation.md"
      ;;
    "TAG")
      printf '%s' "tag-observation.md"
      ;;
    "Nexitally")
      printf '%s' "nexitally-observation.md"
      ;;
    "BoostNet")
      printf '%s' "boostnet-observation.md"
      ;;
    "悠兔")
      printf '%s' "youtu-observation.md"
      ;;
    "唯兔云")
      printf '%s' "weitu-observation.md"
      ;;
    "Fastlink")
      printf '%s' "fastlink-observation.md"
      ;;
    "大哥云")
      printf '%s' "dageyun-observation.md"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

extract_field_value() {
  file_path="$1"
  field_name="$2"

  awk -v field_name="$field_name" '
    {
      line = $0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
    }

    index(line, field_name "：") == 1 {
      value = substr(line, length(field_name "：") + 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      gsub(/`/, "", value)
      print value
      exit
    }
  ' "$file_path"
}

awk -F'|' '
  /^\|/ {
    name = $2
    level = $3
    checked = $5
    status = $6

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", level)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", checked)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)

    if (name != "" && name != "名称" && name !~ /^-+$/) {
      printf("%s\t%s\t%s\t%s\n", name, level, checked, status)
    }
  }
' "$STATUS_BOARD_FILE" > "$TMP_DATA_FILE"

{
  printf '%s\n' "## 状态联动总览"
  printf '\n'
  printf '%s\n' "这张表不是用来重新做一遍推荐，而是让你快速确认：总页现在展示的状态，和各个详情页顶部信息是不是还同步。"
  printf '\n'
  printf '%s\n' "| 名称 | 所在层级 | 当前状态 | 最近检查时间 | 详情页最后更新时间 | 总页同步状态 | 详情页 |"
  printf '%s\n' "|---|---|---|---|---|---|---|"

  while IFS="$(printf '\t')" read -r name level checked status; do
    detail_path=$(detail_path_for_name "$name")
    level_text=$(level_label "$level")

    if [ -n "$detail_path" ]; then
      detail_file="$ROOT_DIR/docs/recommendations/$detail_path"
      detail_updated=$(extract_field_value "$detail_file" "更新日期")
      detail_status=$(extract_field_value "$detail_file" "当前状态")
      detail_level=$(extract_field_value "$detail_file" "总页所在层级")

      sync_status="待同步"
      if [ "$detail_status" = "$status" ] && [ "$detail_level" = "$level_text" ]; then
        sync_status="已同步"
      fi

      detail_link="[查看]($detail_path)"
      detail_updated_display="$detail_updated"
    else
      detail_updated_display="暂未建页"
      sync_status="待建页"
      detail_link="暂未建页"
    fi

    printf '| %s | %s | %s | %s | %s | %s | %s |\n' \
      "$name" \
      "$level_text" \
      "$status" \
      "$checked" \
      "$detail_updated_display" \
      "$sync_status" \
      "$detail_link"
  done < "$TMP_DATA_FILE"

  printf '\n'
  printf '%s\n' "### 这个联动区怎么读"
  printf '\n'
  printf '%s\n' "- \`已同步\`：总页里的层级、状态和详情页顶部信息当前一致"
  printf '%s\n' "- \`待同步\`：详情页已经补了新变化，但总页摘要还没跟上"
  printf '%s\n' "- \`待建页\`：已经进入候补池，但还没有独立详情页"
  printf '%s\n' "- 每次更新候选状态总表或详情页顶部信息后，建议重新运行一次 \`scripts/sync-status-overview.sh\`"
} > "$TMP_BLOCK_FILE"

awk -v block_file="$TMP_BLOCK_FILE" '
  /<!-- STATUS_OVERVIEW:START -->/ {
    print
    while ((getline line < block_file) > 0) {
      print line
    }
    close(block_file)
    in_block = 1
    next
  }

  /<!-- STATUS_OVERVIEW:END -->/ {
    in_block = 0
    print
    next
  }

  in_block != 1 {
    print
  }
' "$GUIDE_FILE" > "$TMP_OUTPUT_FILE"

mv "$TMP_OUTPUT_FILE" "$GUIDE_FILE"

printf '%s\n' "Updated status overview in $GUIDE_FILE"
