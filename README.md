# claude-demo

A small Python repo used to demonstrate the Claude Code GitHub App and its two workflows (`@claude` interactive bot and auto code-review on PRs).

## Quick start

```bash
./demo/reset.sh       # restore baseline (closes PRs/issues, reverts hello.py to buggy)
./demo/preflight.sh   # verify environment is ready
```

Then follow [demo/01-runbook.md](demo/01-runbook.md).

## Repo layout

```
hello.py / test_hello.py     # toy code with intentional bugs
.github/workflows/           # claude.yml + claude-code-review.yml (tuned)
demo/
  00-setup.md                # one-time setup (install app, ruleset, secret)
  01-runbook.md              # repeatable per-demo script
  02-talking-points.md       # narrator notes
  reset.sh                   # idempotent reset between runs
  preflight.sh               # read-only environment check
  snapshot/                  # canonical buggy baseline of hello.py + test_hello.py
```

## Local test

```bash
pip install -r requirements.txt
pytest    # 2 tests fail by design — that's the bug surface for the demo
```
