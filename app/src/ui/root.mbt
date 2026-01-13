// UI ビルダー

pub fn build_root(
  pattern : @signal.Signal[String],
  error : @signal.Signal[String],
  svg_ref : @signal.Signal[@js_dom.Element?],
) -> @dom.DomNode {
  let examples = @data.example_patterns()
  let guide_items = @data.support_items()
  @dom.div(class="app", [
    @components.build_hero(),
    @components.build_layout(pattern, error, svg_ref, examples),
    @components.build_support(guide_items),
  ])
}
