# regex-navi

正規表現の構造をレール図（SVG）として可視化する、軽量な Web アプリです。日本語での理解を助けることを目的としています。

## Features

- 入力した正規表現を即時にレール図へ変換
- React + Vite + TypeScript によるシンプルな実装
- Tailwind CSS ベースのネオブルータリズム UI
- Vitest によるパーサーと SVG 生成のテスト
- Nix flakes + direnv + Bun を前提にした開発環境

## Setup

```bash
direnv allow
bun install
```

direnv を使わない場合:

```bash
nix develop -c bun install
```

## Development

```bash
bun run dev
```

direnv を使わない場合:

```bash
nix develop -c bun run dev
```

開発サーバーは `http://127.0.0.1:5173/` で起動します。

## Test

```bash
bun run test
```

## Build

```bash
bun run build
```

## Supported Regex Syntax

- 連結: `ab`
- 選択: `a|b`
- グループ: `(ab)`
- 量指定: `?`, `+`, `*`, `{m,n}`, `{m}`, `{m,}`
- ワイルドカード: `.`
- アンカー: `^`, `$`
- 文字クラス: `[a-z0-9_]`
- エスケープ: `\` でメタ文字をリテラル化

詳細は [docs/regex-support.md](docs/regex-support.md) を参照してください。

## Project Structure

- `src/ui/`: React UI と表示用データ
- `src/regex/`: 正規表現パーサーと AST
- `src/diagram/`: レール図レイアウトと SVG 生成
- `src/styles.css`: Tailwind エントリと SVG 用スタイル
- `docs/`: 仕様や設計メモ

## Documentation

ドキュメント一覧は [docs/README.md](docs/README.md) から参照できます。
