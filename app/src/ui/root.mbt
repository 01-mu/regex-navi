// UI ビルダー

pub fn build_root(
  pattern : @signal.Signal[String],
  error : @signal.Signal[String],
  svg_ref : @signal.Signal[@js_dom.Element?],
) -> @dom.DomNode {
  let examples = [
    "^hello$",
    "https?://[a-z]+",
    "colou?r",
    "(foo|bar)baz",
    "ab(c|d)+",
    "ab(c|d)*",
    "ab{2,4}c",
    "file\\.(png|jpg)",
    "[a-z]{3,6}\\d?",
    "v1\\.2\\.3",
    "a.+b",
  ]
  @dom.div(class="app", [
    @dom.div(class="hero", [
      @dom.h1([@dom.text("正規表現ナビ")]),
      @dom.p([
        @dom.text("正規表現の構造を分かりやすく可視化します。"),
      ]),
    ]),
    @dom.div(class="layout", [
      @dom.div(class="panel panel-input", [
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
            @dom.text("対応: (), 連結, |, ?, +, *, {m,n}, ., ^, $, 文字クラス, \\\\ エスケープ"),
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
      @dom.div(class="panel panel-output", [
        @dom.h2([@dom.text("出力")]),
        @dom.div(
          class="svg-wrap",
          ref_=fn(el) { svg_ref.set(Some(el)) },
          [],
        ),
      ]),
    ]),
  ])
}
