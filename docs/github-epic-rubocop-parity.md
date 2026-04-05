# GitHub epic: RuboCop Lint parity (KGI)

**Created:** https://github.com/sorafujitani/nobunaga/issues/1 — use that issue as the live tracker; this file remains a template reference.

Create **one epic issue** in English. Suggested title:

`[KGI] RuboCop Lint/* parity tracker`

## Labels

The automation token used in this environment could not create labels (403). **Repository admins** should add the following labels manually if desired:

## Suggested labels (create in the repo if missing)

| Label | Purpose |
|-------|---------|
| `kgi:rubocop-parity` | Epic and child issues for parity work |
| `cop:lint` | Lint department cops |
| `parity:not-started` | Not implemented |
| `parity:partial` | Known gaps vs RuboCop |
| `parity:done` | Matches agreed fixtures |

## Epic body (copy-paste)

```markdown
## KGI

Track **parity with RuboCop’s built-in Lint cops** (baseline version: see `docs/rubocop-parity.md`) as a primary success metric.

## Definitions

- **Implemented**: `rule_id` matches the RuboCop cop name, and agreed fixtures show matching offense locations vs RuboCop (message equality may be relaxed; document tolerances per cop).
- **Partial**: Only a subset of cases match, or messages differ while locations match.
- **Not started**: No meaningful implementation yet.

## Child issues

- Default: one child issue per `Lint/<CopName>`, labeled `kgi:rubocop-parity`.
- Titles: e.g. `[Parity] Implement Lint/BigDecimalNew`.

## Update rules

- When a cop lands in `main`, close the child issue and refresh the summary table in this epic and in `docs/rubocop-parity.md`.

## Summary

| Cop | Issue | Status |
|-----|-------|--------|
| Lint/BigDecimalNew | (link when filed) | Implemented (see parity test) |
```

## Child issue template

**Title:** `[Parity] Implement Lint/<CopName>`

**Body:**

```markdown
## Goal

Match RuboCop `Lint/<CopName>` for the fixtures listed below.

## Fixtures

- (add paths under `test/fixtures/parity/`)

## Known deltas vs RuboCop

- (document any intentional differences)

## RuboCop reference

- Version: (from `docs/rubocop-parity.md`)
```
