export type RepeatKind =
  | { type: "optional" }
  | { type: "oneOrMore" }
  | { type: "zeroOrMore" }
  | { type: "range"; min: number; max: number | null };

export type RegexNode =
  | { type: "empty" }
  | { type: "literal"; text: string }
  | { type: "charClass"; text: string }
  | { type: "concat"; nodes: RegexNode[] }
  | { type: "alt"; nodes: RegexNode[] }
  | { type: "repeat"; node: RegexNode; kind: RepeatKind };

export const emptyNode = (): RegexNode => ({ type: "empty" });

class Parser {
  readonly chars: string[];
  pos = 0;

  constructor(input: string) {
    this.chars = Array.from(input);
  }

  eof() {
    return this.pos >= this.chars.length;
  }

  peek() {
    return this.chars[this.pos];
  }

  next() {
    const value = this.chars[this.pos];
    if (value !== undefined) {
      this.pos += 1;
    }
    return value;
  }

  consume(ch: string) {
    if (this.peek() !== ch) {
      return false;
    }
    this.pos += 1;
    return true;
  }
}

export const parseRegex = (input: string): RegexNode => {
  const parser = new Parser(input);
  const node = parseAlt(parser);

  if (!parser.eof()) {
    throw new Error(`位置${parser.pos}以降に解析できない文字があります`);
  }

  return node;
};

const isDigit = (ch: string) => ch >= "0" && ch <= "9";

const parseNumber = (parser: Parser) => {
  let value = 0;
  let hasDigit = false;

  while (true) {
    const current = parser.peek();
    if (current === undefined || !isDigit(current)) {
      break;
    }
    value = value * 10 + (current.charCodeAt(0) - "0".charCodeAt(0));
    parser.next();
    hasDigit = true;
  }

  if (!hasDigit) {
    throw new Error("数値が必要です");
  }

  return value;
};

const parseAlt = (parser: Parser): RegexNode => {
  const nodes = [parseConcat(parser)];

  while (parser.consume("|")) {
    nodes.push(parseConcat(parser));
  }

  return nodes.length === 1 ? nodes[0] : { type: "alt", nodes };
};

const parseConcat = (parser: Parser): RegexNode => {
  const nodes: RegexNode[] = [];

  while (true) {
    const current = parser.peek();
    if (current === undefined || current === ")" || current === "|") {
      break;
    }
    nodes.push(parseRepeat(parser));
  }

  if (nodes.length === 0) {
    return emptyNode();
  }

  const merged = mergeLiterals(nodes);
  return merged.length === 1 ? merged[0] : { type: "concat", nodes: merged };
};

const isAnchorLiteral = (text: string) => text === "開始" || text === "終了";

const mergeLiterals = (nodes: RegexNode[]) => {
  const merged: RegexNode[] = [];
  let buffer = "";

  for (const node of nodes) {
    if (node.type === "literal" && !isAnchorLiteral(node.text)) {
      buffer += node.text;
      continue;
    }
    if (buffer.length > 0) {
      merged.push({ type: "literal", text: buffer });
      buffer = "";
    }
    merged.push(node);
  }

  if (buffer.length > 0) {
    merged.push({ type: "literal", text: buffer });
  }

  return merged;
};

const parseRepeat = (parser: Parser): RegexNode => {
  const node = parseAtom(parser);
  const current = parser.peek();

  if (current === "*") {
    parser.next();
    return { type: "repeat", node, kind: { type: "zeroOrMore" } };
  }
  if (current === "+") {
    parser.next();
    return { type: "repeat", node, kind: { type: "oneOrMore" } };
  }
  if (current === "?") {
    parser.next();
    return { type: "repeat", node, kind: { type: "optional" } };
  }
  if (current === "{") {
    return parseRange(parser, node);
  }

  return node;
};

const parseRange = (parser: Parser, node: RegexNode): RegexNode => {
  parser.next();
  const min = parseNumber(parser);
  const max = parser.consume(",")
    ? parser.peek() === "}"
      ? null
      : parseNumber(parser)
    : min;

  if (!parser.consume("}")) {
    throw new Error("'}'がありません");
  }

  return { type: "repeat", node, kind: { type: "range", min, max } };
};

const parseAtom = (parser: Parser): RegexNode => {
  const current = parser.peek();

  if (current === undefined) {
    throw new Error("入力の末尾が不完全です");
  }
  if (current === "(") {
    parser.next();
    const inner = parseAlt(parser);
    if (!parser.consume(")")) {
      throw new Error(`位置${parser.pos}に')'がありません`);
    }
    return inner;
  }
  if (current === "[") {
    return parseCharClass(parser);
  }
  if (current === "\\") {
    return parseEscape(parser);
  }
  if (current === ".") {
    parser.next();
    return { type: "literal", text: "任意" };
  }
  if (current === "^") {
    parser.next();
    return { type: "literal", text: "開始" };
  }
  if (current === "$") {
    parser.next();
    return { type: "literal", text: "終了" };
  }
  if (current === ")") {
    throw new Error(`位置${parser.pos}で')'が不正です`);
  }
  if (current === "|") {
    throw new Error(`位置${parser.pos}で'|'が不正です`);
  }

  parser.next();
  return { type: "literal", text: current };
};

const parseEscape = (parser: Parser): RegexNode => {
  parser.next();
  const current = parser.next();

  if (current === undefined) {
    throw new Error("末尾のエスケープが不完全です");
  }

  return {
    type: "literal",
    text: isMetaChar(current) ? current : `\\${current}`,
  };
};

const isMetaChar = (ch: string) =>
  [
    ".",
    "^",
    "$",
    "|",
    "?",
    "+",
    "*",
    "(",
    ")",
    "[",
    "]",
    "{",
    "}",
    "\\",
  ].includes(ch);

const parseCharClass = (parser: Parser): RegexNode => {
  parser.next();
  const chars: string[] = [];

  while (true) {
    const current = parser.next();
    if (current === undefined) {
      throw new Error("文字クラスが閉じられていません");
    }
    if (current === "]") {
      break;
    }
    if (current === "\\") {
      const escaped = parser.next();
      if (escaped === undefined) {
        throw new Error("文字クラス内のエスケープが不完全です");
      }
      chars.push("\\", escaped);
      continue;
    }
    chars.push(current);
  }

  return { type: "charClass", text: `[${chars.join("")}]` };
};
