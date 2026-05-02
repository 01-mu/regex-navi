import { describe, expect, it } from "vitest";
import { parseRegex } from "./parser";

describe("parseRegex", () => {
  it("groups adjacent literals while preserving anchors", () => {
    expect(parseRegex("^hello$")).toEqual({
      type: "concat",
      nodes: [
        { type: "literal", text: "開始" },
        { type: "literal", text: "hello" },
        { type: "literal", text: "終了" },
      ],
    });
  });

  it("parses alternation and repeat ranges", () => {
    expect(parseRegex("ab(c|d){2,4}")).toMatchObject({
      type: "concat",
      nodes: [
        { type: "literal", text: "ab" },
        {
          type: "repeat",
          kind: { type: "range", min: 2, max: 4 },
          node: { type: "alt" },
        },
      ],
    });
  });

  it("reports incomplete character classes", () => {
    expect(() => parseRegex("[a-z")).toThrow("文字クラスが閉じられていません");
  });
});
