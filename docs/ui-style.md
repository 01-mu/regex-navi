# UI Style

## Visual Direction

- Base style: neo-brutalism.
- Priorities: high contrast, bold structure, and clarity over polish.
- The app should feel like a practical visual tool, not a marketing page.

## Color & Typography

- Use crisp backgrounds with hard-edged panels and thick borders.
- Prefer strong accent colors such as cobalt, orange, rose, and yellow against light bases.
- Use readable Japanese fonts for UI text.
- Use a monospace font for regex input, examples, and diagram labels.
- Avoid negative letter spacing.

## Components

- Panels: solid fills, 3px borders, and hard drop shadows.
- Buttons: chunky, high-contrast, with hover states that shift color and position.
- Inputs: monospace text, visible focus state, and clear error state.
- Diagram output: scrollable on small screens and centered after updates.
- Cards: use only for repeated guide items and keep radius small.

## Diagram Styling

- Lines use dark strokes with square joins by default.
- Literal and character-class boxes use yellow fill with dark borders.
- Repetition labels use rose text with a light stroke for readability.
- Start/end markers make the rail direction explicit.

## Accessibility

- Maintain readable contrast ratios, especially for Japanese text.
- Keep text from overlapping controls at mobile widths.
- Preserve horizontal scrolling for diagrams wider than the viewport.
- Use real button elements for examples.
