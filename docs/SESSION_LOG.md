# セッションログ

このファイルは、作業内容・判断・未完了タスクを時系列で残すためのログです。
Codexセッションの文脈を引き継ぐ目的で継続的に追記します。

## 2026-01-12
- ネオブルータリズムの配色を「玩具箱」寄りに調整
- SVGに開始点（円）と終点（矢印）マーカーを追加
- SVGの線/箱/マーカー配色と入力フォーカスの強調を調整
- `styles/` 配下にCSSを分割（`base.css` / `rail.css`）
- 分岐線と枠線の干渉を避けるため、線端の余白を追加
- 中断前に `docs/regex-support.md` へ未対応の記号一覧を追記
- `docs/README.md` にセッションログへのリンクを追加
- Cloudflare Pages へのデプロイ方針を GitHub Actions に決定
- `.github/workflows/deploy-pages.yml` を追加（MoonBit install → build → Pages deploy）
- リポジトリ名/README表記を `regex-navi` に変更
- `gh repo rename` とローカルディレクトリのリネームを実施

未完了:
- SVGの線幅/影/マーカーサイズの微調整
- 例パターンの追加や文言整理
- Cloudflare Pages の Secrets 設定（`CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`）

## 2026-01-13
- MoonBit の CLI インストール手順を最新URLへ更新し、CIで `moon update` を実行するよう調整
- Cloudflare Pages の Actions で `deployments: write` を付与
- main へのPRは dev からのみ許可するチェックを追加（`Require dev into main`）
- `dev` 運用を明文化し、Jujutsu のブックマーク運用ルールを `AGENTS.md` に追記
- モバイルでは「出力」→「入力」の順に並ぶようレイアウト変更（見出しも「出力」に）
- 連続リテラルを1ボックスに統合（`http` など）
- `^`/`$` の表記を「開始/終了」に変更し、アンカーはボックス結合しない
- 繰り返し記号の補足ラベルを追加・位置/デザインを調整（`+` は丸み強化）
- `{m,n}` 表記を `m回` / `m〜n回` / `m回以上` に変更
- 例パターンを複数追加（`a+b+c+` / `file\\.(png|jpg)` など）
- `dev` → `main` のPRを作成してマージ済み
- GitHub branch protection の required check 名を実際の `enforce-dev-source` に合わせて修正（Terraform適用）

未完了:
- SVGの線幅/影/マーカーサイズの微調整（必要なら）
