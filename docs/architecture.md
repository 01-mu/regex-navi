# Architecture

## Stack
- MoonBit for parsing, state, and rendering logic.
- Luna UI (@dom/@signal) for UI composition and reactivity.
- Vite + vite-plugin-moonbit for dev server and build.

## Module Responsibilities
- `app/src/`: MoonBit modules own application state and UI.
- `app/main.ts`: thin bootstrap that imports CSS and the MoonBit module.
- `app/index.html`: container only; avoid app logic here.

## Data Flow
1) User input updates a MoonBit signal.
2) Parser builds an AST.
3) Renderer converts AST into SVG markup.
4) UI swaps the SVG output in the DOM.

## Implementation Policy
- Prefer MoonBit implementations for parsing and rendering.
- Use Luna UI components and signals wherever possible; keep TypeScript minimal.
- If JS interop is needed, wrap it behind small MoonBit-facing helpers.

## Build Flow
- `npm run dev`: Vite dev server with MoonBit watch builds.
- `npm run build`: `moon build` then Vite bundles for production.
