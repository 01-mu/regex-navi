import type { RegexNode, RepeatKind } from "../regex/parser";

export type Shape =
  | {
      type: "line";
      x1: number;
      y1: number;
      x2: number;
      y2: number;
      className: string;
    }
  | {
      type: "rect";
      x: number;
      y: number;
      width: number;
      height: number;
      className: string;
    }
  | { type: "text"; x: number; y: number; text: string; className: string }
  | { type: "circle"; cx: number; cy: number; r: number; className: string }
  | { type: "path"; d: string; className: string; dx: number; dy: number };

export type Diagram = {
  width: number;
  height: number;
  entryY: number;
  exitY: number;
  shapes: Shape[];
};

export const layout = (node: RegexNode): Diagram => {
  switch (node.type) {
    case "empty":
      return layoutSkip(40);
    case "literal":
    case "charClass":
      return layoutBox(node.text);
    case "concat":
      return layoutConcat(node.nodes);
    case "alt":
      return layoutAlt(node.nodes);
    case "repeat":
      return layoutRepeat(node.node, node.kind);
  }
};

const layoutBox = (text: string): Diagram => {
  const padding = 10;
  const width = Math.max(text.length * 8 + padding * 2, 40);
  const height = 28;

  return {
    width,
    height,
    entryY: height / 2,
    exitY: height / 2,
    shapes: [
      { type: "rect", x: 0, y: 0, width, height, className: "rr-box" },
      { type: "text", x: width / 2, y: height / 2, text, className: "rr-text" },
    ],
  };
};

const layoutSkip = (width: number): Diagram => {
  const height = 20;
  const y = height / 2;

  return {
    width,
    height,
    entryY: y,
    exitY: y,
    shapes: [
      { type: "line", x1: 0, y1: y, x2: width, y2: y, className: "rr-line" },
    ],
  };
};

const layoutConcat = (nodes: RegexNode[]): Diagram => {
  if (nodes.length === 0) {
    return layoutSkip(40);
  }
  if (nodes.length === 1) {
    return layout(nodes[0]);
  }

  const gap = 20;
  const edgeGap = 3;
  const layouts = nodes.map(layout);
  const height = Math.max(...layouts.map((child) => child.height));
  const centerY = height / 2;
  const shapes: Shape[] = [];
  let x = 0;

  layouts.forEach((child, index) => {
    shapes.push(...offsetShapes(child.shapes, x, centerY - child.entryY));
    if (index > 0) {
      shapes.push({
        type: "line",
        x1: x - gap + edgeGap,
        y1: centerY,
        x2: x - edgeGap,
        y2: centerY,
        className: "rr-line",
      });
    }
    x += child.width + (index < layouts.length - 1 ? gap : 0);
  });

  return { width: x, height, entryY: centerY, exitY: centerY, shapes };
};

const layoutAlt = (nodes: RegexNode[]): Diagram => {
  if (nodes.length === 1) {
    return layout(nodes[0]);
  }

  const gap = 20;
  const pad = 20;
  const edgeGap = 3;
  const layouts = nodes.map(layout);
  const maxWidth = Math.max(...layouts.map((child) => child.width));
  const totalHeight = layouts.reduce(
    (sum, child, index) =>
      sum + child.height + (index < layouts.length - 1 ? gap : 0),
    0,
  );
  const entryY = totalHeight / 2;
  const rightX = pad + maxWidth + pad;
  const shapes: Shape[] = [];
  let y = 0;
  let topBranch = 0;
  let bottomBranch = 0;

  layouts.forEach((child, index) => {
    const branchY = y + child.entryY;
    if (index === 0) {
      topBranch = branchY;
    }
    if (index === layouts.length - 1) {
      bottomBranch = branchY;
    }
    shapes.push(...offsetShapes(child.shapes, pad, y));
    shapes.push({
      type: "line",
      x1: 0,
      y1: branchY,
      x2: pad - edgeGap,
      y2: branchY,
      className: "rr-line",
    });
    shapes.push({
      type: "line",
      x1: pad + child.width + edgeGap,
      y1: branchY,
      x2: rightX,
      y2: branchY,
      className: "rr-line",
    });
    y += child.height + gap;
  });

  shapes.push({
    type: "line",
    x1: 0,
    y1: topBranch,
    x2: 0,
    y2: bottomBranch,
    className: "rr-line",
  });
  shapes.push({
    type: "line",
    x1: rightX,
    y1: topBranch,
    x2: rightX,
    y2: bottomBranch,
    className: "rr-line",
  });

  return { width: rightX, height: totalHeight, entryY, exitY: entryY, shapes };
};

const layoutRepeat = (inner: RegexNode, kind: RepeatKind): Diagram => {
  const child = layout(inner);
  const pad = 20;
  const edgeGap = 3;
  const loopGap =
    kind.type === "oneOrMore" || kind.type === "zeroOrMore"
      ? 32
      : kind.type === "range"
        ? 26
        : 18;
  const allowBypass =
    kind.type === "optional" ||
    kind.type === "zeroOrMore" ||
    (kind.type === "range" && kind.min === 0);
  const allowLoop =
    kind.type === "oneOrMore" ||
    kind.type === "zeroOrMore" ||
    (kind.type === "range" && (kind.max ?? kind.min + 1) > 1);
  const loopOutset =
    allowLoop && (kind.type === "range" || inner.type === "alt") ? 14 : 0;
  const width = child.width + pad * 2 + loopOutset * 2;
  const height = child.height + loopGap * 2;
  const entryY = loopGap + child.entryY;
  const childX = pad + loopOutset;
  const shapes: Shape[] = [
    ...offsetShapes(child.shapes, childX, loopGap),
    {
      type: "line",
      x1: 0,
      y1: entryY,
      x2: childX - edgeGap,
      y2: entryY,
      className: "rr-line",
    },
    {
      type: "line",
      x1: childX + child.width + edgeGap,
      y1: entryY,
      x2: width,
      y2: entryY,
      className: "rr-line",
    },
  ];
  const bypassY = loopGap / 2;
  const loopY = height - loopGap / 2;

  if (allowBypass) {
    shapes.push({
      type: "path",
      d: bypassPath(width, entryY, bypassY),
      className: "rr-line",
      dx: 0,
      dy: 0,
    });
  }

  if (allowLoop) {
    const loopRadius =
      (kind.type === "oneOrMore" ? 14 : 8) + (loopOutset > 0 ? 4 : 0);
    const loopClass =
      kind.type === "range" ? "rr-repeat-line" : "rr-repeat-soft";
    const loopLeft = childX;
    const loopRight = childX + child.width;
    const d =
      loopOutset > 0
        ? loopPathOutsetLr(
            loopLeft,
            loopRight,
            entryY,
            loopY,
            loopRadius,
            loopOutset,
            loopOutset,
          )
        : loopPath(loopLeft, loopRight, entryY, loopY, loopRadius);
    shapes.push({ type: "path", d, className: loopClass, dx: 0, dy: 0 });
  }

  if (kind.type === "range") {
    shapes.push({
      type: "text",
      x: width / 2,
      y: kind.min === 0 ? labelTopY(bypassY) : labelBottomY(loopY, height),
      text: rangeLabel(kind.min, kind.max),
      className: "rr-label",
    });
  }
  if (kind.type === "oneOrMore") {
    shapes.push({
      type: "text",
      x: width / 2,
      y: labelBottomY(loopY, height),
      text: "1回以上",
      className: "rr-label",
    });
  }
  if (kind.type === "zeroOrMore") {
    shapes.push({
      type: "text",
      x: width / 2,
      y: labelBottomY(loopY, height),
      text: "0回以上",
      className: "rr-label",
    });
  }

  return { width, height, entryY, exitY: entryY, shapes };
};

const clampRadius = (radius: number, dx: number, dy: number) =>
  Math.min(radius, Math.min(Math.abs(dx) / 2, Math.abs(dy) / 2));

const bypassPath = (width: number, entryY: number, bypassY: number) => {
  const radius = clampRadius(8, width, entryY - bypassY);
  return `M 0 ${entryY} L 0 ${bypassY + radius} Q 0 ${bypassY} ${radius} ${bypassY} L ${width - radius} ${bypassY} Q ${width} ${bypassY} ${width} ${bypassY + radius} L ${width} ${entryY}`;
};

const loopPath = (
  leftX: number,
  rightX: number,
  entryY: number,
  loopY: number,
  radiusHint: number,
) => {
  const radius = clampRadius(radiusHint, rightX - leftX, loopY - entryY);
  return `M ${rightX} ${entryY} L ${rightX} ${loopY - radius} Q ${rightX} ${loopY} ${rightX - radius} ${loopY} L ${leftX + radius} ${loopY} Q ${leftX} ${loopY} ${leftX} ${loopY - radius} L ${leftX} ${entryY}`;
};

const loopPathOutsetLr = (
  leftX: number,
  rightX: number,
  entryY: number,
  loopY: number,
  radiusHint: number,
  leftOutset: number,
  rightOutset: number,
) => {
  const radius = clampRadius(
    radiusHint,
    rightX - leftX + leftOutset + rightOutset,
    loopY - entryY,
  );
  const sx = rightX + rightOutset;
  const lx = leftX - leftOutset;
  return `M ${rightX} ${entryY} L ${sx} ${entryY} L ${sx} ${loopY - radius} Q ${sx} ${loopY} ${sx - radius} ${loopY} L ${lx + radius} ${loopY} Q ${lx} ${loopY} ${lx} ${loopY - radius} L ${lx} ${entryY} L ${leftX} ${entryY}`;
};

const rangeLabel = (min: number, max: number | null) => {
  if (max === null) {
    return `${min}回以上`;
  }
  return max === min ? `${min}回` : `${min}〜${max}回`;
};

const labelTopY = (bypassY: number) => Math.max(bypassY - 12, 10);

const labelBottomY = (loopY: number, height: number) =>
  Math.min(loopY + 30, height - 2);

export const offsetShapes = (
  shapes: Shape[],
  dx: number,
  dy: number,
): Shape[] =>
  shapes.map((shape) => {
    switch (shape.type) {
      case "line":
        return {
          ...shape,
          x1: shape.x1 + dx,
          y1: shape.y1 + dy,
          x2: shape.x2 + dx,
          y2: shape.y2 + dy,
        };
      case "rect":
        return { ...shape, x: shape.x + dx, y: shape.y + dy };
      case "text":
        return { ...shape, x: shape.x + dx, y: shape.y + dy };
      case "circle":
        return { ...shape, cx: shape.cx + dx, cy: shape.cy + dy };
      case "path":
        return { ...shape, dx: shape.dx + dx, dy: shape.dy + dy };
    }
  });
