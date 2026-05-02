import { useMemo } from "react";
import { buildFallbackSvg, buildSvg } from "../../diagram/svg";

type DiagramResult = {
  svg: string;
  error: string;
};

export const useDiagramResult = (pattern: string): DiagramResult =>
  useMemo(() => {
    const trimmed = pattern.trim();
    if (trimmed.length === 0) {
      return { svg: buildFallbackSvg(), error: "" };
    }

    try {
      return { svg: buildSvg(pattern), error: "" };
    } catch (error) {
      return {
        svg: buildFallbackSvg(),
        error: error instanceof Error ? error.message : "解析できませんでした",
      };
    }
  }, [pattern]);
