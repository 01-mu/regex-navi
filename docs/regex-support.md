# Regex Support

## Intended Core Syntax (MVP)
- Concatenation: `ab`
- Alternation: `a|b`
- Grouping: `(ab)`
- Quantifiers: `?`, `+`, `*`, `{m,n}`
- Wildcard: `.`
- Anchors: `^`, `$`
- Character classes: `[a-z0-9_]`
- Escape sequences: `\\` for literal meta characters

## Out of Scope / Not Yet
- Lookarounds: `(?=...)`, `(?!...)`
- Flags and inline modifiers
- Unicode classes and complex escapes

## Unsupported Symbols / Constructs
- Non-capturing or named groups: `(?:...)`, `(?<name>...)`, `(?P<name>...)`
- Lookarounds: `(?=...)`, `(?!...)`, `(?<=...)`, `(?<!...)`
- Inline flags: `(?i)`, `(?m)` など
- Lazy/possessive quantifiers: `*?`, `+?`, `{m,n}?`, `*+`, `++`
- Shorthand classes/anchors: `\\d`, `\\w`, `\\s`, `\\b`, `\\A`, `\\Z`, `\\G`
- Backreferences: `\\1`, `\\k<name>`, `(?P=name)`
- Char class extensions: `[^...]` の否定、`[a-z]` などの範囲展開

## Notes
- The goal is visual clarity, not strict engine compatibility.
- When a construct is unsupported, the UI should surface a simple error message.

## Regex Samples (JavaScript / ECMAScript)

### Basic

#### 前後の空白をトリム
- 目的: replace
- パターン: `/^\s+|\s+$/g`
- フラグ: `g`
- 入力例: 成功 `"  hello world  "` / 失敗・境界 `""`
- 期待結果: `"hello world"` / 空文字はそのまま
- 注意: 末尾/先頭のUnicode空白も対象。

#### 連続スペースを1つに
- 目的: replace
- パターン: `/[ \t]+/g`
- フラグ: `g`
- 入力例: 成功 `"a   b\t\tc"` / 失敗・境界 `"abc"`
- 期待結果: `"a b c"` / 単一スペースは変更なし
- 注意: 改行は対象外。

#### 日付 YYYY-MM-DD
- 目的: validate
- パターン: `/^(19|20)\d{2}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/`
- フラグ: なし
- 入力例: 成功 `"2024-02-29"` / 失敗・境界 `"2024-13-01"`
- 期待結果: 形式として妥当ならマッチ
- 注意: 月日の厳密性は未検証（2/30も通る）。

#### 郵便番号（日本）
- 目的: validate
- パターン: `/^\d{3}-?\d{4}$/`
- フラグ: なし
- 入力例: 成功 `"150-0001"` / 失敗・境界 `"1500-001"`
- 期待結果: 7桁＋任意ハイフンでマッチ
- 注意: 実在の地域コードは検証しない。

#### IPv4
- 目的: validate
- パターン: `/^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}$/`
- フラグ: なし
- 入力例: 成功 `"192.168.0.1"` / 失敗・境界 `"256.0.0.1"`
- 期待結果: 0-255のドット4つ形式にマッチ
- 注意: `001` のような先頭ゼロを許容。

### Practical

#### 実用的なメールアドレス
- 目的: validate
- パターン: `/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i`
- フラグ: `i`
- 入力例: 成功 `"user.name+tag@example.co.jp"` / 失敗・境界 `"user@@example.com"`
- 期待結果: よくある形式にマッチ
- 注意: RFC完全準拠ではない。

#### URL（http/https）
- 目的: validate
- パターン: `/^https?:\/\/[^\s/$.?#].[^\s]*$/i`
- フラグ: `i`
- 入力例: 成功 `"https://example.com/path?x=1"` / 失敗・境界 `"ftp://example.com"`
- 期待結果: http/https URLにマッチ
- 注意: ゆるい判定で過剰に通す。

#### セマンティックバージョン
- 目的: validate
- パターン: `/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/`
- フラグ: なし
- 入力例: 成功 `"1.2.3-alpha.1+build.7"` / 失敗・境界 `"01.2.3"`
- 期待結果: SemVerの基本形式にマッチ
- 注意: 先頭ゼロは不許可。

#### Markdown見出し抽出
- 目的: extract
- パターン: `/^(#{1,6})\s+(.+)$/gm`
- フラグ: `gm`
- 入力例: 成功 `"# Title\n## Sub"` / 失敗・境界 `"No heading"`
- 期待結果: 見出しレベルと本文をキャプチャ
- 注意: 末尾の`#`やSetextは非対応。

#### 時刻 HH:MM
- 目的: validate
- パターン: `/^([01]\d|2[0-3]):[0-5]\d$/`
- フラグ: なし
- 入力例: 成功 `"09:30"` / 失敗・境界 `"24:00"`
- 期待結果: 00:00〜23:59にマッチ
- 注意: 24:00は不許可。

### Technique

#### 連続単語の検出（後方参照）
- 目的: extract
- パターン: `/\b(\w+)\s+\1\b/gi`
- フラグ: `gi`
- 入力例: 成功 `"This is is a test"` / 失敗・境界 `"This is a test"`
- 期待結果: 同一単語の連続を検出
- 注意: `\w` はASCII寄り。

#### パスワード強度（先読み）
- 目的: validate
- パターン: `/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$/`
- フラグ: なし
- 入力例: 成功 `"StrongPass1"` / 失敗・境界 `"weakpass"`
- 期待結果: 小/大文字/数字を含む8文字以上
- 注意: 記号は許可しない設計。

#### 拡張子抽出
- 目的: extract
- パターン: `/\.([a-z0-9]+)(?:\?.*)?$/i`
- フラグ: `i`
- 入力例: 成功 `"photo.JPG?size=large"` / 失敗・境界 `"README"`
- 期待結果: 拡張子をキャプチャ
- 注意: `.env` のようなドットファイルも拡張子扱い。

#### CSVの簡易分割
- 目的: split
- パターン: `/\s*,\s*/`
- フラグ: なし
- 入力例: 成功 `"a, b, c"` / 失敗・境界 `"a,\"b,c\""`
- 期待結果: `["a","b","c"]` に分割
- 注意: クォート内のカンマは非対応。

#### HTMLタグ抽出（簡易）
- 目的: extract
- パターン: `/<([a-z][a-z0-9-]*)(\s[^>]*)?>/gi`
- フラグ: `gi`
- 入力例: 成功 `"<div class='x'>"` / 失敗・境界 `"<<notatag>>"`
- 期待結果: タグ名と属性を抽出
- 注意: HTML全体の正確な解析は不可。

### Caution

#### 危険な正規表現（ReDoS教材）
- 目的: validate
- パターン: `/^(a+)+$/`
- フラグ: なし
- 入力例: 成功 `"aaaaaa"` / 失敗・境界 `"aaaaaaaaaaaaaaaaab"`
- 期待結果: すべて`a`ならマッチ、失敗時に極端に遅くなる
- 注意: 未検証入力に使わないこと。

#### ユーザー名（ASCIIのみ）
- 目的: validate
- パターン: `/^[a-zA-Z0-9_]{3,16}$/`
- フラグ: なし
- 入力例: 成功 `"user_123"` / 失敗・境界 `"ab"`
- 期待結果: 3〜16文字のASCIIのみ
- 注意: 日本語やハイフンは不可。

#### 電話番号（JP風・ゆるめ）
- 目的: validate
- パターン: `/^0\d{1,3}-\d{1,4}-\d{4}$/`
- フラグ: なし
- 入力例: 成功 `"03-1234-5678"` / 失敗・境界 `"0312345678"`
- 期待結果: ハイフン付きにマッチ
- 注意: 実在する市外局番の検証はしない。

#### 16進カラーコード
- 目的: validate
- パターン: `/^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/`
- フラグ: なし
- 入力例: 成功 `"#1a2B3c"` / 失敗・境界 `"#1234"`
- 期待結果: 3桁/6桁のHEXにマッチ
- 注意: 8桁（アルファ）は非対応。

#### ダブルクォート文字列の抽出
- 目的: extract
- パターン: `/"([^"\\]*(?:\\.[^"\\]*)*)"/g`
- フラグ: `g`
- 入力例: 成功 `"a \"quoted\" word"` / 失敗・境界 `"unterminated`
- 期待結果: エスケープ込みの中身をキャプチャ
- 注意: テンプレート文字列やシングルクォートは対象外。
