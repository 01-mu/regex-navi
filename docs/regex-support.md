# Regex Support

## Intended Core Syntax

- Concatenation: `ab`
- Alternation: `a|b`
- Grouping: `(ab)`
- Quantifiers: `?`, `+`, `*`, `{m,n}`, `{m}`, `{m,}`
- Wildcard: `.`
- Anchors: `^`, `$`
- Character classes: `[a-z0-9_]`
- Escape sequences: `\` for literal meta characters

## Display Semantics

- Consecutive literals are merged into one diagram box.
- `.` is displayed as `任意`.
- `^` is displayed as `開始`.
- `$` is displayed as `終了`.
- `?` and `{0,n}` draw a bypass route.
- `+`, `*`, and repeated ranges draw a loop route when useful.
- `{m}` displays `m回`.
- `{m,n}` displays `m〜n回`.
- `{m,}` displays `m回以上`.

## Out of Scope / Not Yet

- Lookarounds: `(?=...)`, `(?!...)`, `(?<=...)`, `(?<!...)`
- Flags and inline modifiers
- Unicode classes and complex escapes
- Lazy or possessive quantifiers
- Backreferences
- Matching sample strings

## Unsupported Constructs

- Non-capturing or named groups: `(?:...)`, `(?<name>...)`, `(?P<name>...)`
- Inline flags: `(?i)`, `(?m)`
- Lazy/possessive quantifiers: `*?`, `+?`, `{m,n}?`, `*+`, `++`
- Shorthand classes/anchors: `\d`, `\w`, `\s`, `\b`, `\A`, `\Z`, `\G`
- Backreferences: `\1`, `\k<name>`, `(?P=name)`
- Character class semantics such as negation or range expansion

## Notes

- The goal is visual clarity, not strict engine compatibility.
- Character-class content is displayed as written; it is not expanded or semantically analyzed.
- Unknown escaped non-meta characters are displayed with their backslash, for example `\d`.
- Unsupported constructs may be parsed as simpler visible pieces unless the parser reaches an explicit syntax error.
