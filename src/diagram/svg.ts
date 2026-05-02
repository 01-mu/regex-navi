import { emptyNode, parseRegex } from "../regex/parser";
import { type Diagram, type Shape, layout, offsetShapes } from "./layout";

export const buildSvg = (pattern: string) =>
  renderSvg(layout(parseRegex(pattern)));

export const buildFallbackSvg = () => renderSvg(layout(emptyNode()));

export const renderSvg = (diagram: Diagram) => {
  const pad = 28;
  const width = diagram.width + pad * 2;
  const height = diagram.height + pad * 2;
  const markerRadius = 7;
  const startX = markerRadius + 2;
  const endX = width - markerRadius - 2;
  const entryY = pad + diagram.entryY;
  const exitY = pad + diagram.exitY;
  const shapes: Shape[] = [
    {
      type: "circle",
      cx: startX,
      cy: entryY,
      r: markerRadius,
      className: "rr-marker",
    },
    {
      type: "path",
      d: arrowPath(endX, exitY, markerRadius),
      className: "rr-marker",
      dx: 0,
      dy: 0,
    },
    {
      type: "line",
      x1: startX + markerRadius,
      y1: entryY,
      x2: pad,
      y2: entryY,
      className: "rr-line",
    },
    {
      type: "line",
      x1: pad + diagram.width,
      y1: exitY,
      x2: endX - markerRadius,
      y2: exitY,
      className: "rr-line",
    },
    ...offsetShapes(diagram.shapes, pad, pad),
  ];

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">${shapes.map(shapeToSvg).join("")}</svg>`;
};

const shapeToSvg = (shape: Shape) => {
  switch (shape.type) {
    case "line":
      return `<line class="${shape.className}" x1="${shape.x1}" y1="${shape.y1}" x2="${shape.x2}" y2="${shape.y2}" />`;
    case "rect":
      return `<rect class="${shape.className}" x="${shape.x}" y="${shape.y}" width="${shape.width}" height="${shape.height}" rx="4" ry="4" />`;
    case "text":
      return `<text class="${shape.className}" x="${shape.x}" y="${shape.y}" text-anchor="middle" dominant-baseline="middle">${escapeXml(shape.text)}</text>`;
    case "circle":
      return `<circle class="${shape.className}" cx="${shape.cx}" cy="${shape.cy}" r="${shape.r}" />`;
    case "path":
      return shape.dx === 0 && shape.dy === 0
        ? `<path class="${shape.className}" d="${shape.d}" />`
        : `<path class="${shape.className}" d="${shape.d}" transform="translate(${shape.dx} ${shape.dy})" />`;
  }
};

const escapeXml = (input: string) =>
  input
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");

const arrowPath = (cx: number, cy: number, size: number) =>
  `M ${cx - size} ${cy - size} L ${cx - size} ${cy + size} L ${cx + size} ${cy} Z`;
