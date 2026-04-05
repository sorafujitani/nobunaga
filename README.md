# nobunaga

Ruby linter with a **Rust native extension** (Magnus + Prism via `ruby-prism`). Ruby オーケストレーション層が CLI・ファイル走査・autocorrect を担当し、解析と `Lint/BigDecimalNew` などの AST ルールはネイティブで実行します。

## Requirements

- **Ruby** 3.1+
- **Rust** stable（`rust-toolchain.toml` 参照; `ruby-prism` は新しめの rustc が必要）
- `cargo`, `clang` / ビルドツール（`rb-sys` が Ruby ヘッダにリンク）

## CLI

```bash
bundle exec nobunaga check [paths...]   # default: .
bundle exec nobunaga check --format json [paths...]
bundle exec nobunaga fix [paths...]     # safe autocorrect (in-place)
```

- **`check`** — offenses を表示; 違反があれば終了コード `1`
- **`check --format json`** — 診断の JSON 配列（エディタ・CI 向け）
- **`fix`** — 重ならない `Correction` を適用し、残りを表示; 残違反があれば `1`

## Native engine

- `Nobunaga::Native.inspect_source(path, source)` → 診断の配列（Hash 互換）
- **Prism 構文エラー** → `rule_id`: `Syntax/PrismParseError`
- **Lint/BigDecimalNew** → RuboCop と同じ cop 名（parity テストあり）

## RuboCop parity (KGI)

- [docs/rubocop-parity.md](docs/rubocop-parity.md) — 基準バージョンと定義
- [docs/github-epic-rubocop-parity.md](docs/github-epic-rubocop-parity.md) — GitHub 用エピック Issue テンプレ（英語）

## Development

```bash
bundle config set --local path vendor/bundle   # optional: user-writable gems
bundle install
bundle exec rake test    # compiles ext → lib/nobunaga/nobunaga.so then runs tests
```

ビルドは **`rb_sys` + `ext/nobunaga/extconf.rb`** 経由で libruby にリンクします（macOS CI でのリンクエラー対策）。ルートの `Cargo.toml` はワークスペース定義、`Cargo.lock` はリポジトリにコミットします。

手動: `rake compile` または `cargo clippy` / `cargo build`（`--manifest-path ext/nobunaga/Cargo.toml --locked`）

## License

MIT — see [LICENSE](LICENSE).
