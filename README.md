# regex-navi

MoonBit で正規表現の構造をレール図（SVG）として可視化する、軽量な Web アプリです。日本語での理解を助けることを目的としています。

## リリース
- https://regex-navi.pages.dev/

## 特徴
- 入力した正規表現を即時にレール図へ変換
- ネオブルータリズムのUIで可読性を重視
- MoonBit + Vite 構成で軽量に動作

## セットアップ
作業は `app/` で行います。

```bash
cd app
npm install
```

## 開発
```bash
cd app
npm run dev
```

## ビルド
```bash
cd app
npm run build
```

## 対応している正規表現（MVP）
- 連結: `ab`
- 選択: `a|b`
- グループ: `(ab)`
- 量指定: `?`, `+`, `*`, `{m,n}`
- ワイルドカード: `.`
- アンカー: `^`, `$`
- 文字クラス: `[a-z0-9_]`
- エスケープ: `\\` でメタ文字をリテラル化

詳細は `docs/regex-support.md` を参照してください。

## 主要ディレクトリ
- `app/`: MoonBit + Vite のアプリ本体
- `app/src/`: MoonBit コード
- `docs/`: 仕様や設計メモ

## ドキュメント
ドキュメント一覧は `docs/README.md` から参照できます。
