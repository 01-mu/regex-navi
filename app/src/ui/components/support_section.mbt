// ガイド

fn with_soft_breaks(parts : Array[String]) -> Array[@dom.DomNode] {
  let nodes : Array[@dom.DomNode] = []
  for i = 0; i < parts.length(); i = i + 1 {
    nodes.push(@dom.span(class="soft-chunk", [@dom.text(parts[i])]))
    if i < parts.length() - 1 {
      nodes.push(@dom.create_element("wbr", [], []))
    }
  }
  nodes
}

pub fn build_support(items : Array[(String, Array[String])]) -> @dom.DomNode {
  @dom.section(class="support", [
    @dom.h2([@dom.text("正規表現ガイド")]),
    @dom.div(class="support-grid", items.map(fn(item) {
      let (token, desc_parts) = item
      @dom.div(class="support-card", [
        @dom.div(class="support-token", [@dom.text(token)]),
        @dom.p(class="soft-wrap", with_soft_breaks(desc_parts)),
      ])
    })),
  ])
}
