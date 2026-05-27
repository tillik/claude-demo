#!/usr/bin/env bash
# Reset claude-demo to a clean baseline before a new demo run.
# Idempotent: safe to run multiple times.
#
# What it does:
#   1. Closes all open issues and PRs.
#   2. Deletes leftover claude/* and break-* branches on the remote.
#   3. Restores hello.py / test_hello.py from demo/snapshot/ (buggy baseline).
#   4. Commits and pushes the baseline if anything changed.
#
# Requires admin on the repo (uses ruleset bypass to push to main directly).

set -euo pipefail

REPO="tillik/claude-demo"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Pre-flight"
gh auth status >/dev/null
gh repo view "$REPO" >/dev/null

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$current_branch" != "main" ]; then
  echo "ERROR: must be on 'main' branch (currently on '$current_branch')." >&2
  echo "Run: git checkout main" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: working tree has uncommitted changes. Commit or stash first." >&2
  exit 1
fi

echo "==> Closing open issues"
gh issue list -R "$REPO" --state open --json number --jq '.[].number' \
  | while read -r n; do
      [ -n "$n" ] && gh issue close -R "$REPO" "$n" --reason "not planned" >/dev/null && echo "   closed issue #$n"
    done

echo "==> Closing open PRs"
gh pr list -R "$REPO" --state open --json number --jq '.[].number' \
  | while read -r n; do
      [ -n "$n" ] && gh pr close -R "$REPO" "$n" --delete-branch >/dev/null 2>&1 && echo "   closed PR #$n"
    done

echo "==> Deleting stale remote branches"
git fetch --prune origin >/dev/null
for ref in $(git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||'); do
  case "$ref" in
    claude/*|break-*|add-claude-github-actions-*)
      git push origin --delete "$ref" >/dev/null && echo "   deleted $ref"
      ;;
  esac
done

echo "==> Restoring snapshot files"
cp demo/snapshot/hello.py hello.py
cp demo/snapshot/test_hello.py test_hello.py

if ! git diff --quiet hello.py test_hello.py; then
  git add hello.py test_hello.py
  git commit -m "Reset demo baseline" >/dev/null
  git push origin main >/dev/null
  echo "   committed and pushed baseline"
else
  echo "   already at baseline"
fi

echo "==> Done. Ready for next demo run."
