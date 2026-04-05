# RuboCop parity contract

## Baseline

- **Pinned RuboCop version (development / CI):** `1.69.2` (see `Gemfile` / `nobunaga.gemspec` development dependencies).
- **KGI scope (default):** `Lint/*` cops. Other departments (e.g. `Layout/*`, `Style/*`) are out of scope for the Lint parity KGI unless explicitly added here.

## `rule_id`

- For RuboCop cops, **`Offense#rule_id` must equal the RuboCop cop name** (e.g. `Lint/BigDecimalNew`).
- **Parser diagnostics** are not RuboCop cops. Nobunaga uses **`Syntax/PrismParseError`** for Prism parse errors until a RuboCop-aligned naming scheme is adopted.

## Equality (parity tests)

For each **Implemented** cop we track:

1. **Location:** same **line number** as RuboCop for the primary offense on agreed fixtures (see `test/parity/`).
2. **Message:** may differ; document tolerances in this file or in the child GitHub issue.
3. **Autocorrect:** optional in v1; `Layout/TrailingWhitespace` and similar use Nobunaga’s `Correction` pipeline.

## Summary

| Cop | Status | Notes |
|-----|--------|--------|
| `Lint/Debugger` | Partial | Native: `debugger` and `binding.pry` only (RuboCop default set is larger); line parity in `test/parity/debugger_test.rb` |
| `Lint/BigDecimalNew` | Implemented | Native engine (Prism AST); line vs RuboCop checked in `test/parity/big_decimal_new_test.rb` |
| `Layout/TrailingWhitespace` | Implemented | Ruby engine; autocorrect supported |
| `Syntax/PrismParseError` | Implemented | Native Prism parse errors; not a RuboCop cop |

## References

- RuboCop source (MIT): [rubocop/rubocop](https://github.com/rubocop/rubocop)
- **Tracking epic (GitHub):** https://github.com/sorafujitani/nobunaga/issues/1
- Epic issue template: [github-epic-rubocop-parity.md](github-epic-rubocop-parity.md)
