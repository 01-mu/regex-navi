# Repository Guidelines

## Project Structure & Module Organization

- `app/src/ui/` contains React components and display data.
- `app/src/regex/` contains the regex parser and AST types.
- `app/src/diagram/` contains railroad-diagram layout and SVG rendering.
- `app/src/test/` contains shared Vitest setup.
- `app/public/` stores static assets such as the favicon.
- `docs/` stores product, architecture, and contributor documentation.

## Build, Test, and Development Commands

Use direnv with the Nix flake:

- `direnv allow`: load Bun and Node from `flake.nix`.
- `bun install`: install dependencies from `package.json`.
- `bun run dev`: start Vite at `http://127.0.0.1:5173/`.
- `bun run test`: run Vitest.
- `bun run build`: create a production build.
- `bun run check`: run Biome checks.

Without direnv, prefix commands with `nix develop -c`, for example `nix develop -c bun run test`.

## Coding Style & Naming Conventions

- Indentation: 2 spaces in TS/TSX/CSS/JSON/Markdown.
- TypeScript: prefer `const`, precise types at module boundaries, and pure helpers for parser/layout logic.
- React: keep UI state in components and core regex/diagram logic in `app/src/regex/` and `app/src/diagram/`.
- CSS: prefer Tailwind utilities for layout and component styling; use `app/src/styles.css` for global styles and SVG classes.
- UI copy and user-facing strings should be Japanese unless there is a clear reason not to.
- Add concise Japanese comments only where they explain non-obvious behavior.

## Testing Guidelines

- Add focused Vitest tests for parser behavior and SVG/layout output when changing regex or diagram logic.
- Run `bun run test` after behavioral changes.
- Documentation-only edits do not require test execution.

## Commit & Pull Request Guidelines

- Use short Conventional Commit subjects, for example `feat: add regex examples`.
- Keep commits scoped to one coherent change.
- PRs should include a summary, test steps, and screenshots/gifs for visual changes.

## Security & Configuration Tips

- Do not commit secrets.
- Do not read `.env` files directly.
- Prefer documented placeholders or `.env.example` if configuration becomes necessary.
