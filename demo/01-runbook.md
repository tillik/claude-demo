# Demo runbook

Repeatable Claude Code + GitHub demo. Run `./demo/reset.sh` first, then walk through each scenario.

## Visibility lifecycle (between demos)

**Default state: private.** The repo only goes public when actively demoing — this eliminates the public `@claude` trigger surface as an attack vector when nobody's watching.

**Arm (before demo):**
```bash
gh repo edit tillik/claude-demo --visibility public
# Confirm ruleset enforcement resumed (was suspended while private on free tier):
gh api repos/tillik/claude-demo/rulesets | jq '.[] | {name, enforcement}'
# If the ruleset is missing or inactive, re-create it using the JSON in demo/00-setup.md.
./demo/preflight.sh
```

**Disarm (after demo):**
```bash
gh repo edit tillik/claude-demo --visibility private
```

**What survives the toggle:** commits, workflows, the `CLAUDE_CODE_OAUTH_TOKEN` secret, the `claude` App installation, issues, PRs, collaborators.
**What's affected:** rulesets are not *enforced* on a private repo (free tier) but the definition persists; Actions minutes start drawing from the 2000-min monthly quota while private.

## Preparation (~10 seconds)

```bash
./demo/reset.sh         # restores baseline state
./demo/preflight.sh     # verifies environment is ready
```

The baseline:
- `hello.py` has two bugs (`add` subtracts instead of adds; `average` crashes on empty list).
- `main` is clean. No open issues or PRs. No `claude/*` branches.

---

## Scenario 1 — Interactive `@claude` fixes a bug

**Goal:** show `@claude` triggered by a GitHub issue, producing a PR (not a direct commit).

```bash
gh issue create -R tillik/claude-demo \
  --title "@claude fix the failing tests" \
  --body "@claude pytest is failing on test_add and test_average_empty. Please diagnose the bugs in hello.py and open a PR with the fix."
```

**What to watch:**
1. Actions tab → `Claude Code` workflow starts within ~10s.
2. Bot pushes to a `claude/<topic>` branch (not `main`).
3. Bot opens a PR linked back to the issue.
4. The auto-review workflow (`Claude Code Review`) runs on that PR and posts a structured review.

**Expected time:** 1–3 minutes total.

---

## Scenario 2 — Auto-review on a human PR

**Goal:** show `claude-code-review.yml` reviewing a normal developer PR (no `@claude` mention needed).

```bash
git checkout -b break-add
sed -i 's/return a - b/return a * b/' hello.py
git commit -am "Break add() differently"
git push -u origin break-add
gh pr create -R tillik/claude-demo --fill
```

**What to watch:**
1. PR opens, `Claude Code Review` workflow fires automatically.
2. Within ~1 min, Claude posts a review comment on the PR pointing at the `add()` regression and the still-broken `average([])`.

**Cleanup:** the PR will be closed by the next `reset.sh`.

---

## Scenario 3 — Auto-review on a bot PR (`allowed_bots`)

**Goal:** demonstrate the bot-author guard and the `allowed_bots` opt-in.

The Scenario 1 PR already exhibits this: it was opened by `claude (Bot)`. Show the audience:
- The action's safety guard: `Workflow initiated by non-human actor` — refused unless allowlisted.
- Our `claude-code-review.yml` has `allowed_bots: 'claude'` → the review runs.
- Other bots (Dependabot, Renovate, …) are still blocked.

**Live demonstration option:** temporarily remove `allowed_bots`, push, then re-trigger Scenario 1 to show the failure. Restore afterwards.

---

## Scenario 4 — Ruleset blocks direct push to `main`

**Goal:** prove defense-in-depth. Even if the bot's prompt is bypassed and it tries to push `main`, GitHub refuses.

**Demonstration as the `claude` bot (simulated):**

The bot uses an installation token without admin bypass, so `git push origin main` from inside its action would be rejected with `protected branch hook declined`. Show this by:

1. Cloning the repo with a non-admin token (or use a co-presenter account).
2. Attempting `git push origin main` after a small change.

**Demonstration with the API directly (faster):**

```bash
gh api repos/tillik/claude-demo/rulesets | jq '.[] | {name, enforcement, rules: [.rules[].type]}'
```

Show the ruleset is active, lists `pull_request` + `deletion` + `non_fast_forward`. Then point at the bot's PR (Scenario 1) — explain it had to take this path; direct push wasn't an option.

Admins (you) can still push directly because of the `bypass_actors` entry — that's why `reset.sh` works.

---

## Quick reference: cleanup between runs

```bash
./demo/reset.sh
```

Closes issues/PRs, deletes `claude/*` and `break-*` branches, restores `hello.py` to the buggy baseline, pushes the baseline commit to `main`.
