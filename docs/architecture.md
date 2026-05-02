# Architecture

## Stack

- React for UI composition and state.
- Vite for development server and production bundling.
- TypeScript 6.x for application code.
- Tailwind CSS for layout and component styling.
- Vitest + jsdom for focused tests.
- Biome for formatting and lint checks.
- Bun for dependency management and scripts.
- Nix flakes + direnv for reproducible local tooling.

## Module Responsibilities

- `app/src/main.tsx`: mounts React into `#root` and imports global styles.
- `app/src/ui/App.tsx`: owns input state, renders panels, examples, guide, and SVG output.
- `app/src/ui/data.ts`: example regex patterns and guide content.
- `app/src/regex/parser.ts`: converts supported regex syntax into an AST.
- `app/src/diagram/layout.ts`: converts the AST into diagram dimensions and shapes.
- `app/src/diagram/svg.ts`: converts diagram shapes into escaped SVG markup.
- `app/src/styles.css`: Tailwind entry, global base styles, and SVG class styles.

## Data Flow

1. User input updates React state in `App`.
2. `parseRegex` builds an AST from the pattern.
3. `layout` converts the AST into positioned diagram shapes.
4. `renderSvg` turns those shapes into SVG markup.
5. React inserts the SVG into the output panel and recenters the scroll position.
6. Parser errors show a Japanese message and the output falls back to an empty rail.

## Implementation Policy

- Keep parser, layout, and SVG rendering independent from React.
- Prefer pure functions for regex and diagram logic.
- Escape all text inserted into SVG.
- Keep UI copy in Japanese.
- Add tests near the module being changed when behavior changes.
- Keep Tailwind utilities in components; reserve `app/src/styles.css` for global and SVG-specific CSS.

## Build Flow

- `direnv allow`: loads the flake-provided toolchain.
- `bun install`: installs dependencies and updates `bun.lock`.
- `bun run dev`: starts Vite at `http://127.0.0.1:5173/`.
- `bun run test`: runs Vitest.
- `bun run build`: bundles the app for production.
- `bun run check`: runs Biome checks.
