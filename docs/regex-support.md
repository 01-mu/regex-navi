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

## Notes
- The goal is visual clarity, not strict engine compatibility.
- When a construct is unsupported, the UI should surface a simple error message.
