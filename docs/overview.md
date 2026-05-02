# Overview

## Purpose

regex-navi is a small web app that turns regular expressions into railroad diagrams (SVG) so Japanese programmers can understand regex structure visually.

## Target Users

- Programmers in Japan who read regex but want a quick visual explanation.
- Engineers explaining regex to teammates or documenting patterns.
- Learners who understand examples better when branches and repetition are visible.

## Core Experience

- Type a regex and see the diagram update immediately.
- Choose from example patterns to learn common structures.
- Read a compact guide for supported regex tokens.
- Keep the UI focused: input, examples, parser errors, and one diagram view.

## Scope

- Support common regex building blocks that are easy to visualize.
- Show structure rather than engine-specific matching behavior.
- Keep parser/layout/rendering logic small enough to understand and test.

## Non-Goals

- Full PCRE, Oniguruma, or ECMAScript regex compatibility.
- Runtime matching, replacement, or extraction against sample strings.
- Performance tuning for extremely large patterns.
- Visualizing engine-specific optimizations or backtracking behavior.
