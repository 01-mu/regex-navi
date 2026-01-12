// SVG 生成

pub fn build_svg(pattern : String) -> Result[String, String] {
  match parse_regex(pattern) {
    Ok(ast) => Ok(render_svg(layout(ast)))
    Err(msg) => Err(msg)
  }
}

pub fn render_svg(diagram : Diagram) -> String {
  let pad = 28
  let width = diagram.width + pad * 2
  let height = diagram.height + pad * 2
  let marker_radius = 7
  let start_x = marker_radius + 2
  let end_x = width - marker_radius - 2
  let entry_y = pad + diagram.entry_y
  let exit_y = pad + diagram.exit_y
  let shapes : Array[Shape] = []
  // 始点/終点をマーカーで明示する
  shapes.push(Circle(start_x, entry_y, marker_radius, "rr-marker"))
  shapes.push(Path(arrow_path(end_x, exit_y, marker_radius), "rr-marker", 0, 0))
  shapes.push(Line(start_x + marker_radius, entry_y, pad, entry_y, "rr-line"))
  shapes.push(Line(pad + diagram.width, exit_y, end_x - marker_radius, exit_y, "rr-line"))
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
    Circle(cx, cy, r, class_) =>
      "<circle class=\"" + class_ + "\" cx=\"" + cx.to_string() +
      "\" cy=\"" + cy.to_string() + "\" r=\"" + r.to_string() + "\" />"
    Path(d, class_, dx, dy) =>
      if dx == 0 && dy == 0 {
        "<path class=\"" + class_ + "\" d=\"" + d + "\" />"
      } else {
        "<path class=\"" + class_ + "\" d=\"" + d + "\" transform=\"translate(" +
        dx.to_string() + " " + dy.to_string() + ")\" />"
      }
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

fn arrow_path(cx : Int, cy : Int, size : Int) -> String {
  let sb = StringBuilder::new()
  sb.write_string("M ")
  sb.write_string((cx - size).to_string())
  sb.write_string(" ")
  sb.write_string((cy - size).to_string())
  sb.write_string(" L ")
  sb.write_string((cx - size).to_string())
  sb.write_string(" ")
  sb.write_string((cy + size).to_string())
  sb.write_string(" L ")
  sb.write_string((cx + size).to_string())
  sb.write_string(" ")
  sb.write_string(cy.to_string())
  sb.write_string(" Z")
  sb.to_string()
}
