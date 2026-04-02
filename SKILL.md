---
name: codex-code-review
description: Use when you want an independent second opinion on code changes from a different AI system (Codex/OpenAI), or when the user asks for a Codex review
---

# Codex Code Review

Second opinion from Codex (OpenAI) on your branch's changes. A different model catches different blind spots.

## How to Run

Pipe the review prompt into `codex exec`. Fill in the placeholder and run:

```bash
cat <<'PROMPT' | codex exec --full-auto -o .codex-review.md -
You are reviewing code changes for production readiness.

## What to review

Run this to see the changes:

git diff $(git merge-base main HEAD)

Also check for uncommitted changes:

git diff
git diff --cached

## Context

{DESCRIPTION_OF_WHAT_WAS_CHANGED_AND_WHY}

## Review Checklist

**Code Quality:** Separation of concerns, error handling, type safety, DRY, edge cases
**Architecture:** Design decisions, scalability, performance, security
**Testing:** Tests test real logic (not just mocks), edge cases covered, all passing
**Requirements:** Implementation matches intent, no scope creep, breaking changes documented

## Output Format

### Strengths
[What's well done - be specific with file:line references]

### Issues

#### Critical (Must Fix)
Bugs, security issues, data loss risks, broken functionality

#### Important (Should Fix)
Architecture problems, missing error handling, test gaps

#### Minor (Nice to Have)
Code style, optimization opportunities

**For each issue:** file:line, what's wrong, why it matters, how to fix

### Assessment

**Ready to merge?** [Yes / No / With fixes]
**Reasoning:** [1-2 sentences]
PROMPT
```

**Fill in** `{DESCRIPTION_OF_WHAT_WAS_CHANGED_AND_WHY}` with what you built, the tech stack, and known risk areas.

## After the Review

Read `.codex-review.md` (in the project root) and form your own opinion on each finding. Verify claims against the actual code — Codex may be wrong, may miss context, or may flag things that don't apply. Present the findings to the user with your own assessment of each (agree, disagree, unsure) and why. Do NOT act on them automatically — let the user decide what to address.

## Follow Up with Codex

If you disagree with a finding or want Codex to elaborate, resume the session:

```bash
echo "Your follow-up prompt here" | codex exec resume --last
```

Use this to:

- **Challenge a finding:** "You flagged X in file:line as a bug, but it's intentional because [reason]. Do you still think it's an issue?"
- **Get more detail:** "Explain the security concern in X more concretely — what's the attack vector?"
- **Discuss alternatives:** "You suggested approach A, but we chose B for [reason]. What are the tradeoffs?"

Read the response and update your assessment of the review accordingly. Same rule applies — present findings to the user, don't act automatically.

## Important

- Use `codex exec` (not `codex exec review` — that can't take a custom prompt)
- Use `git merge-base main HEAD` for the diff base — a plain `git diff main` includes commits on main not in your branch
- Set a generous Bash timeout (5+ min) for large diffs
