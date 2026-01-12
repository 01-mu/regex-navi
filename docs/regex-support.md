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
