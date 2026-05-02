import { useEffect, useMemo, useRef, useState } from "react";
import { buildFallbackSvg, buildSvg } from "../diagram/svg";
import { examplePatterns, supportItems } from "./data";

const defaultPattern = "a(b|c)*";

export const App = () => {
  const [pattern, setPattern] = useState(defaultPattern);
  const stageRef = useRef<HTMLDivElement>(null);
  const wrapRef = useRef<HTMLDivElement>(null);

  const result = useMemo(() => {
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
  }, [result.svg]);

  return (
    <main className="mx-auto max-w-[1100px] px-5 py-8 pb-12 font-body text-ink">
      <section className="mb-7 grid gap-2.5 rounded border-[3px] border-ink bg-[#ffe1b3] px-5 py-[18px] shadow-brutal-md">
        <h1 className="m-0 text-[34px] font-bold uppercase tracking-normal">正規表現ナビ</h1>
        <p className="soft-wrap m-0 leading-relaxed text-[#2d2d2d]">
          <span className="soft-chunk">正規表現の構造を</span>
          <wbr />
          <span className="soft-chunk">分かりやすく可視化します。</span>
        </p>
      </section>

      <section className="grid grid-cols-[minmax(260px,1fr)_minmax(360px,1.4fr)] gap-5 max-[900px]:grid-cols-1">
        <div className="panel max-[900px]:order-2">
          <h2 className="mb-3 mt-0 text-lg font-bold">入力</h2>
          <div className="grid gap-3">
            <input
              className="w-full rounded border-[3px] border-ink bg-[#e6fff6] px-4 py-3.5 font-mono text-base shadow-brutal-sm outline-none focus:border-accentBlue focus:border-4 focus:shadow-brutal"
              placeholder="例: (ab|cd)+"
              type="text"
              value={pattern}
              onChange={(event) => setPattern(event.target.value)}
            />
            <div className="flex flex-wrap gap-2">
              {examplePatterns.map((example) => (
                <button
                  className="rounded-sm border-[3px] border-ink bg-[#ffd39a] px-3 py-1.5 text-xs shadow-[3px_3px_0_#151515] transition hover:-translate-x-0.5 hover:-translate-y-0.5 hover:border-accentOrange hover:text-accentOrange hover:shadow-[5px_5px_0_#151515]"
                  key={example}
                  type="button"
                  onClick={() => setPattern(example)}
                >
                  {example}
                </button>
              ))}
            </div>
            {result.error.length > 0 ? (
              <div className="mt-2 whitespace-pre-wrap rounded border-[3px] border-ink bg-[#ffe1ec] px-3.5 py-3 text-[13px] shadow-brutal-sm">
                {result.error}
              </div>
            ) : null}
          </div>
        </div>

        <div className="panel max-[900px]:order-1">
          <h2 className="mb-3 mt-0 text-lg font-bold">出力</h2>
          <div
            className="flex min-h-[260px] w-full items-center justify-start overflow-auto rounded border-[3px] border-dashed border-ink bg-[#f1f6ff] p-4 shadow-brutal-md"
            ref={wrapRef}
          >
            <div
              className="flex min-h-full min-w-full flex-[0_0_auto] items-center justify-center"
              // SVG文字列は自前のエスケープ処理を通した図形だけを差し込む。
              dangerouslySetInnerHTML={{ __html: result.svg }}
              ref={stageRef}
            />
          </div>
        </div>
      </section>

      <section className="mt-7 rounded border-[3px] border-ink bg-[#fef4d6] p-5 shadow-brutal">
        <h2 className="mb-3.5 mt-0 text-lg font-bold">正規表現ガイド</h2>
        <div className="grid grid-cols-[repeat(auto-fit,minmax(180px,1fr))] gap-3">
          {supportItems.map(([token, parts]) => (
            <div className="rounded border-[3px] border-ink bg-[#fffdf4] p-3 shadow-brutal-sm" key={token}>
              <div className="font-mono text-sm font-bold">{token}</div>
              <p className="soft-wrap mb-0 mt-1.5 text-xs text-[#2d2d2d]">
                {parts.map((part, index) => (
                  <span key={part}>
                    <span className="soft-chunk">{part}</span>
                    {index < parts.length - 1 ? <wbr /> : null}
                  </span>
                ))}
              </p>
            </div>
          ))}
        </div>
      </section>

      <footer className="mt-7 text-center text-xs text-[#2d2d2d]">
        <p>Developed by 01-mu.</p>
        <div className="mt-2 flex flex-wrap justify-center gap-2.5">
          <a className="credit-link credit-link--github" href="https://github.com/01-mu/regex-navi" rel="noreferrer" target="_blank">
            GitHub
          </a>
          <a className="credit-link credit-link--x" href="https://x.com/01mu_dev" rel="noreferrer" target="_blank">
            @01mu_dev
          </a>
        </div>
      </footer>
    </main>
  );
};
