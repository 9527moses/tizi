#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TASK="${1:-}"
TARGET_DATE="${TARGET_DATE:-}"
MAX_STALE_DAYS="${MAX_STALE_DAYS:-3}"

usage() {
  cat <<'EOF'
Usage: scripts/run-gitlab-maintenance-task.sh <daily|weekly|sync|closeout>

Run one GitLab CI maintenance task and push changes back to the same project.
EOF
}

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

ensure_target_date() {
  if [ -z "$TARGET_DATE" ]; then
    TARGET_DATE=$(TZ=Asia/Shanghai date +%F)
  fi
}

push_url() {
  if [ -n "${CI_REPOSITORY_URL:-}" ]; then
    printf '%s\n' "$CI_REPOSITORY_URL"
    return
  fi

  if [ -n "${CI_SERVER_PROTOCOL:-}" ] && [ -n "${CI_SERVER_HOST:-}" ] && [ -n "${CI_PROJECT_PATH:-}" ] && [ -n "${CI_JOB_TOKEN:-}" ]; then
    printf '%s://gitlab-ci-token:%s@%s/%s.git\n' \
      "$CI_SERVER_PROTOCOL" \
      "$CI_JOB_TOKEN" \
      "$CI_SERVER_HOST" \
      "$CI_PROJECT_PATH"
    return
  fi

  printf '%s\n' "Unable to determine authenticated GitLab push URL." >&2
  exit 1
}

commit_and_push_if_changed() {
  commit_message="$1"
  shift

  tracked_paths="$*"
  stashed_worktree=0

  git add "$@"

  if git diff --cached --quiet; then
    printf '%s\n' "No changes to commit for task: $TASK"
    return 0
  fi

  if [ "${GITLAB_CI_DRY_RUN:-0}" = "1" ]; then
    git reset --quiet HEAD -- $tracked_paths
    printf '%s\n' "Dry run enabled, skipping commit and push."
    return 0
  fi

  git commit -m "$commit_message"

  if [ -z "${CI_JOB_TOKEN:-}" ]; then
    printf '%s\n' "CI_JOB_TOKEN is required to push changes from GitLab CI." >&2
    exit 1
  fi

  branch_name="${CI_COMMIT_REF_NAME:-main}"

  if [ -n "$(git status --porcelain)" ]; then
    git stash push --include-untracked -m "gitlab-maintenance-pre-rebase" >/dev/null 2>&1
    stashed_worktree=1
  fi

  git fetch origin "$branch_name"
  git rebase "origin/$branch_name"
  git remote set-url origin "$(push_url)"
  git push origin "HEAD:$branch_name"

  if [ "$stashed_worktree" -eq 1 ]; then
    git stash pop >/dev/null 2>&1 || true
  fi
}

run_daily() {
  ensure_target_date

  "$ROOT_DIR/scripts/create-daily-check.sh" "$TARGET_DATE"
  "$ROOT_DIR/scripts/sync-status-overview.sh"
  "$ROOT_DIR/scripts/update-maintenance-dashboard.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS"
  "$ROOT_DIR/scripts/update-ops-summary.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS"

  commit_and_push_if_changed \
    "chore: daily maintenance refresh for ${TARGET_DATE}" \
    research/daily \
    docs/recommendations/airport-guide-2026.md \
    research/maintenance-dashboard.md \
    research/ops-today.md
}

run_weekly() {
  ensure_target_date
  week_label=$(format_date "$TARGET_DATE" "%G-W%V")

  "$ROOT_DIR/scripts/create-weekly-summary.sh" "$TARGET_DATE"
  "$ROOT_DIR/scripts/update-ops-summary.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS"

  commit_and_push_if_changed \
    "chore: create weekly summary for ${week_label}" \
    research/weekly \
    research/ops-today.md
}

run_sync() {
  ensure_target_date

  "$ROOT_DIR/scripts/sync-status-overview.sh"
  "$ROOT_DIR/scripts/update-maintenance-dashboard.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS"
  "$ROOT_DIR/scripts/update-ops-summary.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS"

  commit_and_push_if_changed \
    "chore: sync status overview for ${TARGET_DATE}" \
    docs/recommendations/airport-guide-2026.md \
    research/maintenance-dashboard.md \
    research/ops-today.md
}

run_closeout() {
  ensure_target_date
  report_file="$ROOT_DIR/maintenance-closeout-report.md"

  set +e
  "$ROOT_DIR/scripts/run-maintenance-closeout.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS" --strict > "$report_file"
  exit_code=$?
  set -e

  cat "$report_file"
  "$ROOT_DIR/scripts/update-ops-summary.sh" "$TARGET_DATE" --max-stale-days "$MAX_STALE_DAYS"

  commit_and_push_if_changed \
    "chore: closeout sync maintenance dashboard for ${TARGET_DATE}" \
    docs/recommendations/airport-guide-2026.md \
    research/maintenance-dashboard.md \
    research/ops-today.md

  if [ "$exit_code" -ne 0 ]; then
    exit "$exit_code"
  fi
}

case "$TASK" in
  daily)
    run_daily
    ;;
  weekly)
    run_weekly
    ;;
  sync)
    run_sync
    ;;
  closeout)
    run_closeout
    ;;
  ""|--help|-h)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
