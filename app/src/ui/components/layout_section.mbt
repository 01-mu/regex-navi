// レイアウト

pub fn build_layout(
  pattern : @signal.Signal[String],
  error : @signal.Signal[String],
  svg_ref : @signal.Signal[@js_dom.Element?],
  examples : Array[String],
) -> @dom.DomNode {
  @dom.div(class="layout", [
    build_input_panel(pattern, error, examples),
    build_output_panel(svg_ref),
  ])
}
