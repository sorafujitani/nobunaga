# nobunaga

Ruby linter (early stage): pure-Ruby engine with a **`fix` command** for autocorrect. A native (Rust) engine is planned.

## CLI

```bash
ruby -Ilib exe/nobunaga check [paths...]   # default paths: .
ruby -Ilib exe/nobunaga fix [paths...]     # apply autocorrects in place
```

After `gem install` / `bundle exec`, use `nobunaga` on your `PATH`.

- **`check`** — print offenses; exit `1` if any.
- **`fix`** — apply all non-overlapping corrections, then print any remaining (non-autocorrectable) offenses; exit `1` if any remain.

## Autocorrect model

Each offense may carry `Correction` objects (UTF-8 byte range + replacement). The runner applies them from the end of the file toward the start so indices stay valid. Rules use RuboCop-style `rule_id` values where applicable (e.g. `Layout/TrailingWhitespace`).

## Development

```bash
ruby -Ilib:test test/nobunaga_autocorrect_test.rb
# or, with Bundler:
bundle install
bundle exec rake test
```

## License

MIT — see [LICENSE](LICENSE).
