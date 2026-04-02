# Skills

A collection of agent skills for Claude Code.

## Available Skills

| Skill | Description |
|-------|-------------|
| [codex-code-review](codex-code-review/SKILL.md) | Get an independent second opinion on code changes from Codex (OpenAI) |

## Installation

Add skills to Claude Code using the Skills CLI:

```bash
npx skills add <owner>/<repo>@codex-code-review
```

Replace `<owner>/<repo>` with the GitHub repository path (e.g. `tordrt/skills`).

Alternatively, add skills globally with:

```bash
npx skills add <owner>/<repo>@codex-code-review -g
```
