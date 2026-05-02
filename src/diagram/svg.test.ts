import { describe, expect, it } from "vitest";
import { buildSvg } from "./svg";

describe("buildSvg", () => {
  it("renders labels for repetition", () => {
    expect(buildSvg("ab(c|d)+")).toContain("1回以上");
  });

  it("escapes text inserted into SVG", () => {
    expect(buildSvg("<tag>")).toContain("&lt;tag&gt;");
  });
});
