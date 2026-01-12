// Regex Rail Diagram app

priv enum RepeatKind {
  Optional
  OneOrMore
  ZeroOrMore
}

priv enum RegexNode {
  Empty
  Literal(String)
  CharClass(String)
  Concat(Array[RegexNode])
  Alt(Array[RegexNode])
  Repeat(RegexNode, RepeatKind)
}

priv struct Parser {
  input : String
  chars : Array[Char]
  mut pos : Int
}

fn Parser::new(input : String) -> Parser {
  { input, chars: input.to_array(), pos: 0 }
}

fn Parser::eof(self : Parser) -> Bool {
  self.pos >= self.chars.length()
}

fn Parser::peek(self : Parser) -> Char? {
  if self.pos < self.chars.length() {
    Some(self.chars[self.pos])
  } else {
    None
  }
}

fn Parser::next(self : Parser) -> Char? {
  if self.pos < self.chars.length() {
    let c = self.chars[self.pos]
    self.pos = self.pos + 1
    Some(c)
  } else {
    None
  }
}

fn Parser::consume(self : Parser, ch : Char) -> Bool {
  match self.peek() {
    Some(c) if c == ch => {
      self.pos = self.pos + 1
      true
    }
    _ => false
  }
}

fn parse_regex(input : String) -> Result[RegexNode, String] {
  let parser = Parser::new(input)
  let result = parse_alt(parser)
  match result {
    Ok(node) => {
      if parser.eof() {
        Ok(node)
      } else {
        Err("Unexpected trailing input at position " + parser.pos.to_string())
      }
    }
    Err(msg) => Err(msg)
  }
}

fn parse_alt(parser : Parser) -> Result[RegexNode, String] {
  let mut nodes : Array[RegexNode] = []
  match parse_concat(parser) {
    Ok(node) => nodes.push(node)
    Err(msg) => return Err(msg)
  }
  while parser.consume('|') {
    match parse_concat(parser) {
      Ok(node) => nodes.push(node)
      Err(msg) => return Err(msg)
    }
  }
  if nodes.length() == 1 {
    Ok(nodes[0])
  } else {
    Ok(Alt(nodes))
  }
}

fn parse_concat(parser : Parser) -> Result[RegexNode, String] {
  let mut nodes : Array[RegexNode] = []
  while true {
    match parser.peek() {
      None => break
      Some(')') => break
      Some('|') => break
      _ => ()
    }
    match parse_repeat(parser) {
      Ok(node) => nodes.push(node)
      Err(msg) => return Err(msg)
    }
  }
  if nodes.is_empty() {
    Ok(Empty)
  } else if nodes.length() == 1 {
    Ok(nodes[0])
  } else {
    Ok(Concat(nodes))
  }
}

fn parse_repeat(parser : Parser) -> Result[RegexNode, String] {
  let node = match parse_atom(parser) {
    Ok(value) => value
    Err(msg) => return Err(msg)
  }
  match parser.peek() {
    Some('*') => {
      parser.next() |> ignore
      Ok(Repeat(node, ZeroOrMore))
    }
    Some('+') => {
      parser.next() |> ignore
      Ok(Repeat(node, OneOrMore))
    }
    Some('?') => {
      parser.next() |> ignore
      Ok(Repeat(node, Optional))
    }
    _ => Ok(node)
  }
}

fn parse_atom(parser : Parser) -> Result[RegexNode, String] {
  match parser.peek() {
    None => Err("Unexpected end of input")
    Some('(') => {
      parser.next() |> ignore
      let inner = parse_alt(parser)
      match inner {
        Ok(node) =>
          if parser.consume(')') {
            Ok(node)
          } else {
            Err("Missing ')' at position " + parser.pos.to_string())
          }
        Err(msg) => Err(msg)
      }
    }
    Some('[') => parse_char_class(parser)
    Some('\\') => parse_escape(parser)
    Some(')') => Err("Unexpected ')' at position " + parser.pos.to_string())
    Some('|') => Err("Unexpected '|' at position " + parser.pos.to_string())
    Some(c) => {
      parser.next() |> ignore
      Ok(Literal(char_to_string(c)))
    }
  }
}

fn parse_escape(parser : Parser) -> Result[RegexNode, String] {
  parser.next() |> ignore
  match parser.next() {
    Some(c) => Ok(Literal("\\" + char_to_string(c)))
    None => Err("Dangling escape at end of input")
  }
}

fn parse_char_class(parser : Parser) -> Result[RegexNode, String] {
  parser.next() |> ignore
  let mut buf : Array[Char] = []
  while true {
    match parser.next() {
      None => return Err("Unterminated character class")
      Some(']') => break
      Some('\\') => {
        match parser.next() {
          Some(c) => {
            buf.push('\\')
            buf.push(c)
          }
          None => return Err("Dangling escape in character class")
        }
      }
      Some(c) => buf.push(c)
    }
  }
  let content = String::from_array(buf)
  Ok(CharClass("[" + content + "]"))
}

fn char_to_string(c : Char) -> String {
  let chars : Array[Char] = [c]
  String::from_array(chars)
}

priv enum Shape {
  Line(Int, Int, Int, Int, String)
  Rect(Int, Int, Int, Int, String)
  Text(Int, Int, String, String)
}

priv struct Diagram {
  width : Int
  height : Int
  entry_y : Int
  exit_y : Int
  shapes : Array[Shape]
}

fn layout(node : RegexNode) -> Diagram {
  match node {
    Empty => layout_skip(40)
    Literal(text) => layout_box(text)
    CharClass(text) => layout_box(text)
    Concat(nodes) => layout_concat(nodes)
    Alt(nodes) => layout_alt(nodes)
    Repeat(inner, kind) => layout_repeat(inner, kind)
  }
}

fn layout_box(text : String) -> Diagram {
  let padding = 10
  let min_width = 40
  let char_width = 8
  let calc_width = text.length() * char_width + padding * 2
  let width = if calc_width < min_width { min_width } else { calc_width }
  let height = 28
  let shapes : Array[Shape] = []
  shapes.push(Rect(0, 0, width, height, "rr-box"))
  shapes.push(Text(width / 2, height / 2, text, "rr-text"))
  { width, height, entry_y: height / 2, exit_y: height / 2, shapes }
}

fn layout_skip(width : Int) -> Diagram {
  let height = 20
  let y = height / 2
  let shapes : Array[Shape] = []
  shapes.push(Line(0, y, width, y, "rr-line"))
  { width, height, entry_y: y, exit_y: y, shapes }
}

fn layout_concat(nodes : Array[RegexNode]) -> Diagram {
  if nodes.is_empty() {
    return layout_skip(40)
  }
  if nodes.length() == 1 {
    return layout(nodes[0])
  }
  let gap = 20
  let mut layouts : Array[Diagram] = []
  let mut height = 0
  for node in nodes {
    let child = layout(node)
    if child.height > height {
      height = child.height
    }
    layouts.push(child)
  }
  let center_y = height / 2
  let mut shapes : Array[Shape] = []
  let mut x = 0
  let mut i = 0
  while i < layouts.length() {
    let child = layouts[i]
    let child_y = center_y - child.entry_y
    append_shapes(shapes, offset_shapes(child.shapes, x, child_y))
    if i > 0 {
      let line_start = x - gap
      let line_end = x
      shapes.push(Line(line_start, center_y, line_end, center_y, "rr-line"))
    }
    x = x + child.width
    if i < layouts.length() - 1 {
      x = x + gap
    }
    i = i + 1
  }
  let width = x
  { width, height, entry_y: center_y, exit_y: center_y, shapes }
}

fn layout_alt(nodes : Array[RegexNode]) -> Diagram {
  if nodes.length() == 1 {
    return layout(nodes[0])
  }
  let gap = 20
  let pad = 20
  let mut layouts : Array[Diagram] = []
  let mut max_width = 0
  let mut total_height = 0
  for node in nodes {
    let child = layout(node)
    if child.width > max_width {
      max_width = child.width
    }
    layouts.push(child)
  }
  for i = 0; i < layouts.length(); i = i + 1 {
    total_height = total_height + layouts[i].height
    if i < layouts.length() - 1 {
      total_height = total_height + gap
    }
  }
  let entry_y = total_height / 2
  let left_x = 0
  let right_x = pad + max_width
  let mut shapes : Array[Shape] = []
  let mut y = 0
  let mut top_branch = 0
  let mut bottom_branch = 0
  for i = 0; i < layouts.length(); i = i + 1 {
    let child = layouts[i]
    let child_y = y
    let branch_y = child_y + child.entry_y
    if i == 0 {
      top_branch = branch_y
    }
    if i == layouts.length() - 1 {
      bottom_branch = branch_y
    }
    append_shapes(shapes, offset_shapes(child.shapes, pad, child_y))
    shapes.push(Line(left_x, branch_y, pad, branch_y, "rr-line"))
    shapes.push(Line(pad + child.width, branch_y, right_x, branch_y, "rr-line"))
    y = y + child.height + gap
  }
  shapes.push(Line(left_x, top_branch, left_x, bottom_branch, "rr-line"))
  shapes.push(Line(right_x, top_branch, right_x, bottom_branch, "rr-line"))
  { width: right_x, height: total_height, entry_y, exit_y: entry_y, shapes }
}

fn layout_repeat(inner : RegexNode, kind : RepeatKind) -> Diagram {
  let child = layout(inner)
  let pad = 20
  let loop_gap = 18
  let width = child.width + pad * 2
  let height = child.height + loop_gap * 2
  let entry_y = loop_gap + child.entry_y
  let mut shapes : Array[Shape] = []
  append_shapes(shapes, offset_shapes(child.shapes, pad, loop_gap))
  shapes.push(Line(0, entry_y, pad, entry_y, "rr-line"))
  shapes.push(Line(pad + child.width, entry_y, width, entry_y, "rr-line"))
  if kind == Optional || kind == ZeroOrMore {
    let bypass_y = loop_gap / 2
    shapes.push(Line(0, entry_y, 0, bypass_y, "rr-line"))
    shapes.push(Line(0, bypass_y, width, bypass_y, "rr-line"))
    shapes.push(Line(width, bypass_y, width, entry_y, "rr-line"))
  }
  if kind == OneOrMore || kind == ZeroOrMore {
    let loop_y = height - loop_gap / 2
    shapes.push(Line(pad + child.width, entry_y, pad + child.width, loop_y, "rr-line"))
    shapes.push(Line(pad + child.width, loop_y, pad, loop_y, "rr-line"))
    shapes.push(Line(pad, loop_y, pad, entry_y, "rr-line"))
  }
  { width, height, entry_y, exit_y: entry_y, shapes }
}

fn append_shapes(target : Array[Shape], extra : Array[Shape]) -> Unit {
  for shape in extra {
    target.push(shape)
  }
}

fn offset_shapes(shapes : Array[Shape], dx : Int, dy : Int) -> Array[Shape] {
  let result : Array[Shape] = []
  for shape in shapes {
    match shape {
      Line(x1, y1, x2, y2, class_) =>
        result.push(Line(x1 + dx, y1 + dy, x2 + dx, y2 + dy, class_))
      Rect(x, y, w, h, class_) => result.push(Rect(x + dx, y + dy, w, h, class_))
      Text(x, y, text, class_) => result.push(Text(x + dx, y + dy, text, class_))
    }
  }
  result
}

fn shape_to_svg(shape : Shape) -> String {
  match shape {
    Line(x1, y1, x2, y2, class_) =>
      "<line class=\"" + class_ + "\" x1=\"" + x1.to_string() +
      "\" y1=\"" + y1.to_string() + "\" x2=\"" + x2.to_string() +
      "\" y2=\"" + y2.to_string() + "\" />"
    Rect(x, y, w, h, class_) =>
      "<rect class=\"" + class_ + "\" x=\"" + x.to_string() +
      "\" y=\"" + y.to_string() + "\" width=\"" + w.to_string() +
      "\" height=\"" + h.to_string() + "\" rx=\"8\" ry=\"8\" />"
    Text(x, y, text, class_) =>
      "<text class=\"" + class_ + "\" x=\"" + x.to_string() +
      "\" y=\"" + y.to_string() +
      "\" text-anchor=\"middle\" dominant-baseline=\"middle\">" +
      escape_xml(text) + "</text>"
  }
}

fn escape_xml(input : String) -> String {
  let buf = StringBuilder::new()
  for c in input {
    match c {
      '&' => buf.write_string("&amp;")
      '<' => buf.write_string("&lt;")
      '>' => buf.write_string("&gt;")
      '"' => buf.write_string("&quot;")
      '\'' => buf.write_string("&#39;")
      _ => buf.write_char(c)
    }
  }
  buf.to_string()
}

fn render_svg(diagram : Diagram) -> String {
  let pad = 16
  let width = diagram.width + pad * 2
  let height = diagram.height + pad * 2
  let shapes : Array[Shape] = []
  shapes.push(Line(0, pad + diagram.entry_y, pad, pad + diagram.entry_y, "rr-line"))
  shapes.push(Line(pad + diagram.width, pad + diagram.exit_y, width, pad + diagram.exit_y, "rr-line"))
  append_shapes(shapes, offset_shapes(diagram.shapes, pad, pad))
  let sb = StringBuilder::new()
  sb.write_string("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"")
  sb.write_string(width.to_string())
  sb.write_string("\" height=\"")
  sb.write_string(height.to_string())
  sb.write_string("\" viewBox=\"0 0 ")
  sb.write_string(width.to_string())
  sb.write_string(" ")
  sb.write_string(height.to_string())
  sb.write_string("\">")
  for shape in shapes {
    sb.write_string(shape_to_svg(shape))
  }
  sb.write_string("</svg>")
  sb.to_string()
}

fn build_svg(pattern : String) -> Result[String, String] {
  match parse_regex(pattern) {
    Ok(ast) => Ok(render_svg(layout(ast)))
    Err(msg) => Err(msg)
  }
}

fn main {
  let pattern = @signal.signal("a(b|c)*")
  let error = @signal.signal("")
  let svg = @signal.signal("")
  let svg_ref : Ref[@js_dom.Element?] = { val: None }

  let _ = @signal.effect(fn() {
    let current = pattern.get()
    let trimmed = current.trim().to_string()
    if trimmed.is_empty() {
      error.set("")
      svg.set(render_svg(layout(Empty)))
    } else {
      match build_svg(current) {
        Ok(markup) => {
          error.set("")
          svg.set(markup)
        }
        Err(msg) => {
          error.set(msg)
          svg.set(render_svg(layout(Empty)))
        }
      }
    }
  })

  let _ = @signal.effect(fn() {
    match svg_ref.val {
      Some(el) => el.setInnerHTML(svg.get())
      None => ()
    }
  })

  let examples = [
    "ab(c|d)*",
    "(foo|bar)baz",
    "https?://[a-z]+",
    "colou?r",
  ]

  let doc = @js_dom.document()
  match doc.getElementById("app") {
    Some(el) => {
      let app = @dom.div(class="app", [
        @dom.div(class="hero", [
          @dom.h1([@dom.text("Regex Rail")]),
          @dom.p([
            @dom.text("Visualize regex structure as a rail diagram SVG."),
          ]),
        ]),
        @dom.div(class="layout", [
          @dom.div(class="panel", [
            @dom.h2([@dom.text("Input")]),
            @dom.div(class="input-row", [
              @dom.input(
                type_="text",
                class="regex-input",
                placeholder="Example: (ab|cd)+",
                dyn_value=fn() { pattern.get() },
                on=@dom.events().input(fn(e) {
                  let target = e.target()
                  let input = @js_dom.HTMLInputElement::cast_from_element(target)
                  pattern.set(input.value)
                }),
              ),
              @dom.p(class="hint", [
                @dom.text("Support: (), concat, |, ?, +, *, character classes, \\\\ escape."),
              ]),
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
          ]),
          @dom.div(class="panel", [
            @dom.h2([@dom.text("Rail Diagram")]),
            @dom.div(
              class="svg-wrap",
              ref_=fn(el) { svg_ref.val = Some(el) },
              [],
            ),
          ]),
        ]),
      ])
      @dom.render(el |> @dom.DomElement::from_jsdom, app)
    }
    None => ()
  }
}
