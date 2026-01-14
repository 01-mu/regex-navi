// UI ビルダー

pub fn build_app(
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
    @dom.div(class="credit", [
      @dom.p([@dom.text("Developed by 01-mu.")]),
      @dom.div(class="credit-links", [
        @dom.a(
          class="credit-link credit-link--github",
          href="https://github.com/01-mu/regex-navi",
          target="_blank",
          [@dom.text("GitHub")],
        ),
        @dom.a(
          class="credit-link credit-link--x",
          href="https://x.com/01mu_dev",
          target="_blank",
          [@dom.text("@01mu_dev")],
        ),
      ]),
    ]),
  ])
}
