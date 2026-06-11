# Agent Constitution

This file is the repo-wide contract for agents working in this project.

Keep this file short and durable. Add project-specific rules here only after they are intentionally accepted as constitution-level guidance.

## Constitution

### Naming And Structure

- Use lowercase kebab-case for new directories, for example `apim-setup/` or `token-monitoring/`.
- Keep directory names short, descriptive, and domain-oriented rather than technology-oriented when possible.
- Do not rename existing directories only to satisfy naming style unless the user explicitly asks.
- Keep generated, scratch, and durable project artifacts in their configured locations.

### Tech Stack

- Use Python for scripting, SDK automation, monitoring code, and API utilities.
- Use Terraform for Azure infrastructure provisioning (APIM, Foundry, App Insights, etc.).
- Use Azure CLI (`az`) and REST APIs for operational automation where Terraform is not suitable.
- Guidebook and documentation in Markdown.

### Implementation Structure

- `infra/` — Terraform modules for Azure resource provisioning (APIM, Foundry, App Insights)
- `scripts/` — Python automation scripts (key management, user assignment, monitoring queries)
- `src/` — Reusable Python modules and utilities
- `docs/` — Guidebook, architecture docs, ADRs
- `notebooks/` — Jupyter notebooks for analysis and demonstration
- `tests/` — Tests mirroring `src/` structure

### Python Code Rules

- Follow PEP 8 and the repository's existing Python formatter, linter, and typechecker configuration.
- Use `snake_case` for functions, methods, variables, and modules; use `PascalCase` for classes; use `UPPER_SNAKE_CASE` for constants.
- Prefer type hints on public functions, class methods, dataclasses, and boundary-facing code.
- Keep imports explicit and grouped as standard library, third-party, then local imports.
- Prefer small pure functions and typed data structures for domain logic; use classes when they own state, invariants, or a coherent interface.
- Do not introduce new Python tooling, formatting style, or dependency management conventions unless the task is to set them up.

### Terraform Code Rules

- Use consistent naming: `snake_case` for resource names and variables.
- Keep modules small and focused — one module per logical resource group.
- Use variables with descriptions and type constraints.
- Use `terraform fmt` before committing.

### Git And Commits Rules

- Do not create branches, commit, push, rebase, reset, or stash unless the user explicitly asks.
- When asked to create a branch, use this branch name format:

```text
<type>/<short-kebab-summary>
```

- Use the same branch types as commit types: `feat`, `fix`, `test`, `refactor`, `docs`, `chore`, `perf`, `build`, `ci`, `revert`.
- Keep branch names lowercase, descriptive, and under 64 characters.
- When asked to commit, include only files relevant to the requested task.
- Message should contain a brief one-line summary of the commit.
- Keep the summary imperative, lowercase unless it names a proper noun, and under 72 characters. First letter of the message should be a capital letter.
- Add a commit body only when it explains non-obvious context, tradeoffs, or verification.

## Agent Skills

If `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, or `docs/agents/domain.md` are missing or stale, run the repository setup flow from `.github/skills/setup-matt-pocock-skills/SKILL.md` before using planning, triage, diagnosis, TDD, architecture, or documentation skills.

### Issue Tracker

Issues are tracked in GitHub Issues for `jihys/apim-foundry-cost-governance`. See `docs/agents/issue-tracker.md`.

### Triage Labels

Triage labels use the canonical GitHub label vocabulary. See `docs/agents/triage-labels.md`.

### Domain Docs

Domain docs use a single-context layout. See `docs/agents/domain.md`.
