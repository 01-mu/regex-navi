# Repository Guidelines

## Project Structure & Module Organization
- `app/` is the working directory for the MoonBit + Vite app.
- `app/src/` holds MoonBit source (`lib.mbt`) and compiled output is handled by the MoonBit/Vite plugin.
- `app/main.ts` is the Vite entry that loads the MoonBit module and styles.
- `app/index.html` and `app/style.css` define the UI shell and styling.
- `docs/` stores documentation; start at `docs/README.md` and keep `AGENTS.md` as the primary contributor guide.
- `HANDOFF.md` is a temporary handoff file; delete it once its contents are absorbed into this repo or your session notes.

## Build, Test, and Development Commands
Run commands from `app/`.
- `npm install`: install local dev dependencies.
- `npm run dev`: start Vite dev server at `http://localhost:5173/` with MoonBit watch enabled.
- `npm run build`: run `moon build` then bundle with Vite for production.

## Coding Style & Naming Conventions
- Indentation: 2 spaces in TS/CSS/JSON; follow existing MoonBit formatting in `app/src/lib.mbt`.
- Naming: use lower_snake_case for MoonBit identifiers where consistent; use lowerCamelCase for TS.
- Styling: keep CSS class names kebab-case (e.g., `.regex-input`, `.svg-wrap`).
- No formatter or linter is configured; keep changes consistent with nearby code.
- Add concise Japanese comments where they help explain non-obvious logic.
- Use Japanese copy for UI text and user-facing strings unless there is a clear reason not to.

## Testing Guidelines
- Automated tests are not configured.
- Validate manually by running `npm run dev` and verifying the UI updates as expected.
- If you add tests, document the runner, naming pattern, and command here.

## Commit & Pull Request Guidelines
- History shows short, imperative subjects, sometimes Conventional Commits (e.g., `fix:`). Follow that style.
- PRs should include: summary, manual test steps, and UI screenshots/gifs for visual changes.
- Link related issues when available.

## Security & Configuration Tips
- Do not commit secrets. Prefer `.env.example` with placeholders if config is needed.
- Avoid reading `.env` files directly; request non-secret values for local testing.
