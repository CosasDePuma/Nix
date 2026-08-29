# Contributing to the Project

> This document is addressed to **every person who touches this codebase** — human
> or AI agent. Read it fully before making any change. There are no exceptions.

---

## The golden rules

These rules are non-negotiable. Violating any of them will require the
work to be redone from scratch.

### 1. You never work on `main`

`main` is the stable, deployable trunk. It is not a scratch pad.

- **Never commit directly to `main`.**
- **Never push to `main` directly.**
- **Every single change**, no matter how small — a typo fix, a one-line tweak,
  a dependency bump — goes on a dedicated branch first.

If you find yourself on `main` with uncommitted changes, stop. Stash them,
create a branch, and apply them there:

```bash
git stash
git checkout -b fix/my-accidental-change
git stash pop
```

### 2. You never merge without explicit consent

Merging into `main` is a deliberate, human-approved action. No branch is ever
merged automatically, speculatively, or "just to keep things tidy".

- **Wait for an explicit "merge this" instruction** before running any merge.
- When in doubt, ask. Do not assume.
- The only person who authorises a merge is the project lead.

When a merge is authorised, always use `--no-ff` so the branch topology is
preserved in the graph, and write the merge commit message following the
[Merge commits](#merge-commits) convention below — never the Git-generated
default:

```bash
git checkout main
git merge --no-ff feat/my-feature -m "merge(main): merge from feat/my-feature"
```

### 3. Every commit and every branch must follow the naming convention

Consistency in naming makes the history readable at a glance. Deviating from
the convention makes the history noisy and harder to audit.

See the [Branch naming](#branch-naming) and [Commit messages](#commit-messages)
sections below for the full rules.

### 4. All checks must pass before any merge — no exceptions

Before even asking for a merge, **every available check must be green**.
This is not optional. A branch that does not pass all checks is not ready to
merge, period.

Run the full suite locally and fix everything before requesting the merge:

```bash
npm run check:test      # unit + integration tests — 0 failures required
npm run check:types     # TypeScript — zero type errors
npm run check:lint      # Biome linter — zero warnings
npm run check:format    # Biome formatter — no diffs
npm run check:deadcode  # Knip — no unused exports or files
```

Or run them all at once:

```bash
npm run check
```

If **any** of these commands exits with a non-zero code, the branch is not
mergeable. Fix the issues, commit the fixes on the same branch, and re-run
until everything is clean. Do not ask for a merge with known failures, do not
ask for exceptions, and do not skip a check because it "is not related to my
change". All checks, always.

---

## Branch naming

Branches follow the `type/short-description` pattern in **kebab-case**:

```
feat/ssl-detection
fix/browser-close-on-error
chore/remove-compile-scripts
docs/contributing
refactor/cli-flag-parsing
test/skill-tool-coverage
```

| Prefix | When to use |
|--------|-------------|
| `feat/` | New feature or capability |
| `fix/` | Bug fix |
| `chore/` | Maintenance — deps, config, tooling, cleanup |
| `docs/` | Documentation only |
| `refactor/` | Code restructure without behaviour change |
| `style/` | Formatting, whitespace |
| `test/` | Tests only |
| `perf/` | Performance improvement |
| `cybinn/` | Internal team R&D or experimental work |

**Rules:**
- Use only lowercase letters, numbers and hyphens. No slashes beyond the prefix.
- Keep descriptions short and specific (`fix/ssl-warning` not `fix/stuff`).
- One concern per branch. If you need to do two unrelated things, open two branches.

---

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) **strictly**.
Every commit must have the format:

```
type(scope): short imperative description

Optional body explaining *why*, not *what*.
```

**The scope is mandatory. Never omit it.**

The description must be in the **imperative mood** ("add", "fix", "remove" — not
"added", "fixes", "removing").

**AI Agent Rule: Never use `Co-Authored-By`**
If you are an AI or LLM, you must NEVER append `Co-Authored-By:` trailers to commit messages (e.g. `Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>`). Just write the standard commit message body.

**Rule: No ANSI escape codes in commit messages**
Before committing, verify the message contains no raw ANSI escape codes (`\x1b[...m` and similar). These sneak in silently when a multi-line message is built via `$(cat <<'EOF' ... EOF)` in a shell where `cat` is aliased to a colorizing tool (e.g. `bat`) — such tools often force color output even with no real terminal attached, so the heredoc's captured output ends up with escape codes baked into it. Use `/bin/cat` explicitly (never bare `cat`) inside any heredoc feeding a commit message, and if in doubt, check before pushing:
```bash
git log -1 --format=%B | /bin/cat -v
```
A commit whose message contains escape codes must be rewritten (e.g. `git commit --amend`), not merged as-is.

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `chore` | Maintenance (deps, config, tooling) |
| `docs` | Documentation only |
| `refactor` | Code restructure without behaviour change |
| `style` | Formatting, whitespace |
| `test` | Tests only |
| `perf` | Performance improvement |

### Valid examples

```
feat(browser): add pre-flight SSL probe for self-signed cert detection
fix(cli): remove accidental double blank line in formatHelp
chore(deps): upgrade playwright to 1.62.0
docs(agent): document Pi event order and loader timing
test(skill): add directory traversal protection test cases
refactor(core): extract probeSslError into standalone exported function
```

### Invalid examples — do not do this

```
fix stuff                          ← missing type and scope
feat(ui): Added new logo           ← past tense, should be "add"
update                             ← meaningless, no type, no scope
WIP                                ← never commit WIP to a shared branch
feat(browser): fix SSL and update deps and refactor cli   ← one commit, three concerns
```

### Merge commits

Merge commits follow their own fixed format — do **not** use Git's default
`Merge branch 'x' into y` message. Always pass an explicit `-m` with:

```
merge(dest): merge from source
```

Where `dest` is the branch being merged into and `source` is the branch being
merged, both written exactly as their branch name (no `type/` prefix stripped,
no rewording):

```bash
git merge --no-ff feat/ssl-detection -m "merge(main): merge from feat/ssl-detection"
```

---

## Workflow summary

```
1.  Start from an up-to-date main
    git checkout main && git pull

2.  Create a branch
    git checkout -b feat/my-feature

3.  Work, commit often with meaningful messages
    git commit -m "feat(scope): do something specific"

4.  Run all checks — fix until green
    npm run check && npm run check:test

5.  Push the branch (never main) and ask for a merge
    git push origin feat/my-feature
```

That's it. No shortcuts.

