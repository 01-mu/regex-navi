// 出力パネル

pub fn build_output_panel(svg_ref : @signal.Signal[@js_dom.Element?]) -> @dom.DomNode {
  @dom.div(class="panel panel-output", [
    @dom.h2([@dom.text("出力")]),
    @dom.div(
      class="svg-wrap",
      [
        @dom.div(
          class="svg-stage",
          ref_=fn(el) { svg_ref.set(Some(el)) },
          [],
        ),
      ],
    ),
  ])
}
