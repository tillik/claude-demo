# One-time setup

Run these once per demo environment. After this, use `01-runbook.md` for each demo session.

## 1. Authenticate with the required scope

```bash
gh auth status -h github.com               # check
gh auth refresh -h github.com -s workflow  # add 'workflow' if missing
```

The `workflow` scope is what lets `/install-github-app` create the workflow files.

## 2. Install the Claude Code GitHub App

From inside the cloned repo:

```
/install-github-app
```

This:
- installs the `claude` GitHub App on the repo,
- adds the `CLAUDE_CODE_OAUTH_TOKEN` secret,
- opens a PR adding `.github/workflows/claude.yml` and `.github/workflows/claude-code-review.yml`.

Merge that PR.

## 3. Make the repo public

```bash
gh repo edit tillik/claude-demo --visibility public
```

Required so rulesets are available on the free tier.

## 4. Create the `protect-main` ruleset

```bash
gh api -X POST repos/tillik/claude-demo/rulesets --input - <<'EOF'
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [
    {"actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always"}
  ],
  "conditions": {"ref_name": {"include": ["refs/heads/main"], "exclude": []}},
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false
    }}
  ]
}
EOF
```

- `actor_id: 5` = repository admin role. You can bypass; the `claude` bot cannot.
- `pull_request` rule forces a PR for any merge to `main`.

## 5. Tune the workflows

Two edits already applied in this repo, to be aware of:

- `claude.yml` — has an explicit prompt forcing PR-based workflow and a `--allowed-tools` allowlist.
- `claude-code-review.yml` — has `allowed_bots: 'claude'` so reviews trigger on bot-authored PRs.

## 6. Verify

```bash
./demo/preflight.sh
```

All checks should pass.
