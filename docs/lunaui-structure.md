# LunaUI Directory Layout (Pragmatic)

```
app/src/
  main.mbt
  ui/
    root.mbt
  core/
    diagram/
    regex/
    regex_parser.mbt
    diagram_layout.mbt
    svg_render.mbt
```

## Rationale
- `main.mbt`: Wires signals, effects, and mounts the UI; keep it small.
- `ui/`: Rendering-only code. Receives state and references, does not own logic.
- `core/`: UI-independent logic.
- `core/regex/`: 正規表現のパースとAST生成。
- `core/diagram/`: レール図のレイアウトとSVG生成。

## Naming & Split Rules
- File names: `snake_case`. Types: `CamelCase`.
- Split when a file exceeds ~200 lines or responsibilities mix (parsing + rendering, etc.).
- Prefer: UI -> action -> update -> new state, even for small prototypes.

## Minimal Flow Skeleton (MoonBit-like)
```mbt
pub enum Action {
  SetPattern(String)
  ParseError(String)
}

pub struct AppState {
  pattern : String
  error : String
  svg : String
}

pub fn update(state : AppState, action : Action) -> AppState {
  match action {
    SetPattern(p) => { ... }
    ParseError(msg) => { ... }
  }
}

pub fn root_view(state : AppState, dispatch : (Action) -> Unit) -> @dom.DomNode {
  // UIは state を描画し、dispatch を呼ぶだけ
  ...
}
```
