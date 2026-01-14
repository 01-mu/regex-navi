// ヒーロー

pub fn build_hero() -> @dom.DomNode {
  @dom.div(class="hero", [
    @dom.h1([@dom.text("正規表現ナビ")]),
    @dom.p(class="soft-wrap", [
      @dom.span(class="soft-chunk", [@dom.text("正規表現の構造を")]),
      @dom.create_element("wbr", [], []),
      @dom.span(class="soft-chunk", [@dom.text("分かりやすく可視化します。")]),
    ]),
  ])
}
