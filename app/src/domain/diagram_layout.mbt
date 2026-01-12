// レール図レイアウト

pub enum Shape {
  Line(Int, Int, Int, Int, String)
  Rect(Int, Int, Int, Int, String)
  Text(Int, Int, String, String)
  // 曲線パスは平行移動も保持する
  Path(String, String, Int, Int)
}

pub struct Diagram {
  width : Int
  height : Int
  entry_y : Int
  exit_y : Int
  shapes : Array[Shape]
}

pub fn layout(node : RegexNode) -> Diagram {
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
  let layouts : Array[Diagram] = []
  let mut height = 0
  for node in nodes {
    let child = layout(node)
    if child.height > height {
      height = child.height
    }
    layouts.push(child)
  }
  let center_y = height / 2
  let shapes : Array[Shape] = []
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
  let layouts : Array[Diagram] = []
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
  let shapes : Array[Shape] = []
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
    // 分岐は背骨から水平に接続して視認性を優先
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
  let shapes : Array[Shape] = []
  append_shapes(shapes, offset_shapes(child.shapes, pad, loop_gap))
  shapes.push(Line(0, entry_y, pad, entry_y, "rr-line"))
  shapes.push(Line(pad + child.width, entry_y, width, entry_y, "rr-line"))
  let allow_bypass = match kind {
    Optional => true
    ZeroOrMore => true
    _ => false
  }
  if allow_bypass {
    let bypass_y = loop_gap / 2
    // Optional/ZeroOrMore のバイパスを丸角にする
    shapes.push(Path(bypass_path(width, entry_y, bypass_y), "rr-line", 0, 0))
  }
  let allow_loop = match kind {
    OneOrMore => true
    ZeroOrMore => true
    _ => false
  }
  if allow_loop {
    let loop_y = height - loop_gap / 2
    // 繰り返しループを丸角で描画
    shapes.push(Path(loop_path(pad, pad + child.width, entry_y, loop_y), "rr-line", 0, 0))
  }
  { width, height, entry_y, exit_y: entry_y, shapes }
}

fn min_int(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}

fn abs_int(value : Int) -> Int {
  if value < 0 { -value } else { value }
}

fn clamp_radius(radius : Int, dx : Int, dy : Int) -> Int {
  let limit_x = abs_int(dx) / 2
  let limit_y = abs_int(dy) / 2
  min_int(radius, min_int(limit_x, limit_y))
}

fn bypass_path(width : Int, entry_y : Int, bypass_y : Int) -> String {
  let radius = clamp_radius(8, width, entry_y - bypass_y)
  let sb = StringBuilder::new()
  sb.write_string("M ")
  sb.write_string("0 ")
  sb.write_string(entry_y.to_string())
  sb.write_string(" L 0 ")
  sb.write_string((bypass_y + radius).to_string())
  sb.write_string(" Q 0 ")
  sb.write_string(bypass_y.to_string())
  sb.write_string(" ")
  sb.write_string(radius.to_string())
  sb.write_string(" ")
  sb.write_string(bypass_y.to_string())
  sb.write_string(" L ")
  sb.write_string((width - radius).to_string())
  sb.write_string(" ")
  sb.write_string(bypass_y.to_string())
  sb.write_string(" Q ")
  sb.write_string(width.to_string())
  sb.write_string(" ")
  sb.write_string(bypass_y.to_string())
  sb.write_string(" ")
  sb.write_string(width.to_string())
  sb.write_string(" ")
  sb.write_string((bypass_y + radius).to_string())
  sb.write_string(" L ")
  sb.write_string(width.to_string())
  sb.write_string(" ")
  sb.write_string(entry_y.to_string())
  sb.to_string()
}

fn loop_path(left_x : Int, right_x : Int, entry_y : Int, loop_y : Int) -> String {
  let radius = clamp_radius(8, right_x - left_x, loop_y - entry_y)
  let sb = StringBuilder::new()
  sb.write_string("M ")
  sb.write_string(right_x.to_string())
  sb.write_string(" ")
  sb.write_string(entry_y.to_string())
  sb.write_string(" L ")
  sb.write_string(right_x.to_string())
  sb.write_string(" ")
  sb.write_string((loop_y - radius).to_string())
  sb.write_string(" Q ")
  sb.write_string(right_x.to_string())
  sb.write_string(" ")
  sb.write_string(loop_y.to_string())
  sb.write_string(" ")
  sb.write_string((right_x - radius).to_string())
  sb.write_string(" ")
  sb.write_string(loop_y.to_string())
  sb.write_string(" L ")
  sb.write_string((left_x + radius).to_string())
  sb.write_string(" ")
  sb.write_string(loop_y.to_string())
  sb.write_string(" Q ")
  sb.write_string(left_x.to_string())
  sb.write_string(" ")
  sb.write_string(loop_y.to_string())
  sb.write_string(" ")
  sb.write_string(left_x.to_string())
  sb.write_string(" ")
  sb.write_string((loop_y - radius).to_string())
  sb.write_string(" L ")
  sb.write_string(left_x.to_string())
  sb.write_string(" ")
  sb.write_string(entry_y.to_string())
  sb.to_string()
}

pub fn append_shapes(target : Array[Shape], extra : Array[Shape]) -> Unit {
  for shape in extra {
    target.push(shape)
  }
}

pub fn offset_shapes(shapes : Array[Shape], dx : Int, dy : Int) -> Array[Shape] {
  let result : Array[Shape] = []
  for shape in shapes {
    match shape {
      Line(x1, y1, x2, y2, class_) =>
        result.push(Line(x1 + dx, y1 + dy, x2 + dx, y2 + dy, class_))
      Rect(x, y, w, h, class_) => result.push(Rect(x + dx, y + dy, w, h, class_))
      Text(x, y, text, class_) => result.push(Text(x + dx, y + dy, text, class_))
      Path(d, class_, ox, oy) => result.push(Path(d, class_, ox + dx, oy + dy))
    }
  }
  result
}
