// UI エントリポイント

fn main {
  let pattern = @signal.signal("a(b|c)*")
  let error = @signal.signal("")
  let svg = @signal.signal("")
  let svg_ref : @signal.Signal[@js_dom.Element?] = @signal.signal(None)

  let _ = @signal.effect(fn() {
    let current = pattern.get()
    let trimmed = current.trim().to_string()
    if trimmed.is_empty() {
      error.set("")
      svg.set(@core.render_svg(@core.layout(@core.empty_node())))
    } else {
      match @core.build_svg(current) {
        Ok(markup) => {
          error.set("")
          svg.set(markup)
        }
        Err(msg) => {
          error.set(msg)
          svg.set(@core.render_svg(@core.layout(@core.empty_node())))
        }
      }
    }
  })

  let _ = @signal.effect(fn() {
    match svg_ref.get() {
      Some(el) => el.setInnerHTML(svg.get())
      None => ()
    }
  })

  let doc = @js_dom.document()
  match doc.getElementById("app") {
    Some(el) => {
      let app = @ui.build_root(pattern, error, svg_ref)
      @dom.render(el |> @dom.DomElement::from_jsdom, app)
    }
    None => ()
  }
}
