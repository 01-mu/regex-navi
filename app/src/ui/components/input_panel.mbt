// 入力パネル

pub fn build_input_panel(
  pattern : @signal.Signal[String],
  error : @signal.Signal[String],
  examples : Array[String],
) -> @dom.DomNode {
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
  ])
}
