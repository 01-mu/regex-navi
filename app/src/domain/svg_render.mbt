// SVG 生成

pub fn build_svg(pattern : String) -> Result[String, String] {
  match parse_regex(pattern) {
    Ok(ast) => Ok(render_svg(layout(ast)))
    Err(msg) => Err(msg)
  }
}

pub fn render_svg(diagram : Diagram) -> String {
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
