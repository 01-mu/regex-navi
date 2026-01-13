// ガイド

pub fn build_support(items : Array[(String, String)]) -> @dom.DomNode {
  @dom.section(class="support", [
    @dom.h2([@dom.text("正規表現ガイド")]),
    @dom.div(class="support-grid", items.map(fn(item) {
      let (token, desc) = item
      @dom.div(class="support-card", [
        @dom.div(class="support-token", [@dom.text(token)]),
        @dom.p([@dom.text(desc)]),
      ])
    })),
  ])
}
