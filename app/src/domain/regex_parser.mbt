// 正規表現パーサ (MVP)

pub enum RepeatKind {
  Optional
  OneOrMore
  ZeroOrMore
}

pub enum RegexNode {
  Empty
  Literal(String)
  CharClass(String)
  Concat(Array[RegexNode])
  Alt(Array[RegexNode])
  Repeat(RegexNode, RepeatKind)
}

///|
/// 空ノードの生成
pub fn empty_node() -> RegexNode {
  Empty
}

struct Parser {
  chars : Array[Char]
  mut pos : Int
}

fn Parser::new(input : String) -> Parser {
  { chars: input.to_array(), pos: 0 }
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

pub fn parse_regex(input : String) -> Result[RegexNode, String] {
  let parser = Parser::new(input)
  let result = parse_alt(parser)
  match result {
    Ok(node) => {
      if parser.eof() {
        Ok(node)
      } else {
        Err("位置" + parser.pos.to_string() + "以降に解析できない文字があります")
      }
    }
    Err(msg) => Err(msg)
  }
}

fn parse_alt(parser : Parser) -> Result[RegexNode, String] {
  let nodes : Array[RegexNode] = []
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
  let nodes : Array[RegexNode] = []
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
    None => Err("入力の末尾が不完全です")
    Some('(') => {
      parser.next() |> ignore
      let inner = parse_alt(parser)
      match inner {
        Ok(node) =>
          if parser.consume(')') {
            Ok(node)
          } else {
            Err("位置" + parser.pos.to_string() + "に')'がありません")
          }
        Err(msg) => Err(msg)
      }
    }
    Some('[') => parse_char_class(parser)
    Some('\\') => parse_escape(parser)
    Some(')') => Err("位置" + parser.pos.to_string() + "で')'が不正です")
    Some('|') => Err("位置" + parser.pos.to_string() + "で'|'が不正です")
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
    None => Err("末尾のエスケープが不完全です")
  }
}

fn parse_char_class(parser : Parser) -> Result[RegexNode, String] {
  parser.next() |> ignore
  let buf : Array[Char] = []
  while true {
    match parser.next() {
      None => return Err("文字クラスが閉じられていません")
      Some(']') => break
      Some('\\') => {
        match parser.next() {
          Some(c) => {
            buf.push('\\')
            buf.push(c)
          }
          None => return Err("文字クラス内のエスケープが不完全です")
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
