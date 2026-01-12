# Overview

## Purpose
Regex Rail is a small web app that turns regular expressions into railroad diagrams (SVG) so Japanese programmers can understand regex structure visually.

## Target Users
- Programmers in Japan who read regex but want a quick visual explanation.
- Engineers explaining regex to teammates or documenting patterns.

## Core Experience
- Type a regex and see a diagram update immediately.
- Keep the UI compact: input, hints, and a single diagram view.

## Scope (MVP)
- Support common regex building blocks that are easy to visualize.
- Focus on clarity over completeness; show structure, not engine-specific quirks.

## Non-Goals (for now)
- Full PCRE/Oniguruma parity.
- Performance tuning for huge patterns.
- Advanced testing/coverage automation.
