// ヒーロー

pub fn build_hero() -> @dom.DomNode {
  @dom.div(class="hero", [
    @dom.h1([@dom.text("正規表現ナビ")]),
    @dom.p([
      @dom.text("正規表現の構造を分かりやすく可視化します。"),
    ]),
  ])
}
