#!/usr/bin/env bash
# Verify the repo is ready to demo. Read-only checks.

set -uo pipefail

REPO="tillik/claude-demo"
PASS=0
FAIL=0

check() {
  local name="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  [ok]   $name"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $name"
    FAIL=$((FAIL + 1))
  fi
}

echo "==> Pre-flight checks for $REPO"

check "currently on 'main' branch" \
  "[ \"\$(git rev-parse --abbrev-ref HEAD)\" = 'main' ]"

check "working tree clean (no uncommitted changes)" \
  "[ -z \"\$(git status --porcelain)\" ]"

check "gh authenticated to github.com" \
  "gh auth status -h github.com"

check "github.com token has 'workflow' scope" \
  "gh auth status -h github.com 2>&1 | grep -q 'workflow'"

check "repo is public (rulesets require public on free tier)" \
  "[ \"\$(gh repo view $REPO --json visibility -q .visibility)\" = 'PUBLIC' ]"

check "CLAUDE_CODE_OAUTH_TOKEN secret present" \
  "gh secret list -R $REPO | grep -q CLAUDE_CODE_OAUTH_TOKEN"

check "protect-main ruleset active" \
  "gh api repos/$REPO/rulesets | grep -q '\"name\":\"protect-main\"'"

check "no open issues" \
  "[ \"\$(gh issue list -R $REPO --state open --json number --jq 'length')\" = '0' ]"

check "no open PRs" \
  "[ \"\$(gh pr list -R $REPO --state open --json number --jq 'length')\" = '0' ]"

check "hello.py has the add() bug" \
  "grep -q 'return a - b' hello.py"

check "hello.py lacks empty-list guard in average()" \
  "! grep -q 'if not numbers' hello.py"

check "claude.yml restricts @claude trigger by author_association" \
  "grep -q 'author_association' .github/workflows/claude.yml"

echo ""
echo "==> $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
