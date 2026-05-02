# regex-navi

A lightweight web app that visualizes regular expression structure as railroad diagrams (SVG). The app is designed to help Japanese readers understand regex patterns visually.

## Features

- Converts typed regular expressions into railroad diagrams immediately.
- Uses a small React + Vite + TypeScript implementation.
- Provides a Tailwind CSS-based neo-brutalist UI.
- Tests parser behavior and SVG generation with Vitest.
- Assumes a development environment based on Nix flakes, direnv, and Bun.

## Setup

```bash
direnv allow
bun install
```

Without direnv:

```bash
nix develop -c bun install
```

## Development

```bash
bun run dev
```

Without direnv:

```bash
nix develop -c bun run dev
```

The development server starts at `http://127.0.0.1:5173/`.

## Test

```bash
bun run test
```

## Build

```bash
bun run build
```

## Supported Regex Syntax

- Concatenation: `ab`
- Alternation: `a|b`
- Grouping: `(ab)`
- Quantifiers: `?`, `+`, `*`, `{m,n}`, `{m}`, `{m,}`
- Wildcard: `.`
- Anchors: `^`, `$`
- Character classes: `[a-z0-9_]`
- Escapes: `\` makes meta characters literal

See [docs/regex-support.md](docs/regex-support.md) for details.

## Project Structure

- `app/src/ui/`: React UI and display data
- `app/src/regex/`: regex parser and AST
- `app/src/diagram/`: railroad diagram layout and SVG rendering
- `app/src/styles.css`: Tailwind entry point and SVG styles
- `docs/`: specifications and design notes

## Documentation

The documentation index is available at [docs/README.md](docs/README.md).
