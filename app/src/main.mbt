// UI エントリポイント

fn main {
  let pattern = @signal.signal("a(b|c)*")
  let error = @signal.signal("")
  let svg = @signal.signal("")
  let svg_ref : @signal.Signal[@js_dom.Element?] = @signal.signal(None)

  let _ = @signal.effect(fn() {
    let current = pattern.get()
    let trimmed = current.trim().to_string()
    if trimmed.is_empty() {
      error.set("")
      svg.set(render_svg(layout(Empty)))
    } else {
      match build_svg(current) {
        Ok(markup) => {
          error.set("")
          svg.set(markup)
        }
        Err(msg) => {
          error.set(msg)
          svg.set(render_svg(layout(Empty)))
        }
      }
    }
  })

  let _ = @signal.effect(fn() {
    match svg_ref.get() {
      Some(el) => el.setInnerHTML(svg.get())
      None => ()
    }
  })

  let examples = [
    "ab(c|d)*",
    "(foo|bar)baz",
    "https?://[a-z]+",
    "colou?r",
  ]

  let doc = @js_dom.document()
  match doc.getElementById("app") {
    Some(el) => {
      let app = @dom.div(class="app", [
        @dom.div(class="hero", [
          @dom.h1([@dom.text("正規表現ナビ")]),
          @dom.p([
            @dom.text("正規表現の構造を分かりやすく可視化します。"),
          ]),
        ]),
        @dom.div(class="layout", [
          @dom.div(class="panel", [
            @dom.h2([@dom.text("入力")]),
            @dom.div(class="input-row", [
              @dom.input(
                type_="text",
                class="regex-input",
                placeholder="例: (ab|cd)+",
                dyn_value=fn() { pattern.get() },
                on=@dom.events().input(fn(e) {
                  let target = e.target()
                  let input = @js_dom.HTMLInputElement::cast_from_element(target)
                  pattern.set(input.value)
                }),
              ),
              @dom.p(class="hint", [
                @dom.text("対応: (), 連結, |, ?, +, *, 文字クラス, \\ エスケープ"),
              ]),
              @dom.div(class="example-row", examples.map(fn(value) {
                @dom.button(
                  class="example",
                  on=@dom.events().click(fn(_e) { pattern.set(value) }),
                  [@dom.text(value)],
                )
              })),
              @dom.div(
                class="error",
                dyn_style=fn() { if error.get().is_empty() { "display:none" } else { "" } },
                [@dom.text_dyn(fn() { error.get() })],
              ),
            ]),
          ]),
          @dom.div(class="panel", [
            @dom.h2([@dom.text("図")]),
            @dom.div(
              class="svg-wrap",
              ref_=fn(el) { svg_ref.set(Some(el)) },
              [],
            ),
          ]),
        ]),
      ])
      @dom.render(el |> @dom.DomElement::from_jsdom, app)
    }
    None => ()
  }
}
