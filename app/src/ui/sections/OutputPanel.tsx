import { useEffect, useRef } from "react";

type OutputPanelProps = {
  svg: string;
};

export const OutputPanel = ({ svg }: OutputPanelProps) => {
  const wrapRef = useRef<HTMLDivElement>(null);
  const svgRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const svgElement = svgRef.current;
    if (svgElement) {
      svgElement.innerHTML = svg;
    }
  }, [svg]);

  useEffect(() => {
    const wrap = wrapRef.current;
    if (!wrap) {
      return;
    }

    const center = () => {
      const maxScroll = wrap.scrollWidth - wrap.clientWidth;
      wrap.scrollLeft = maxScroll > 0 ? Math.floor(maxScroll / 2) : 0;
    };

    center();
    window.addEventListener("resize", center);
    return () => window.removeEventListener("resize", center);
  }, [svg]);

  return (
    <div className="panel max-[900px]:order-1">
      <h2 className="mb-3 mt-0 text-lg font-bold">出力</h2>
      <div
        className="flex min-h-[260px] w-full items-center justify-start overflow-auto rounded border-[3px] border-dashed border-ink bg-[#f1f6ff] p-4 shadow-brutal-md"
        ref={wrapRef}
      >
        <div
          className="flex min-h-full min-w-full flex-[0_0_auto] items-center justify-center"
          ref={svgRef}
        />
      </div>
    </div>
  );
};
