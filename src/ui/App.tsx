import { useEffect, useMemo, useRef, useState } from "react";
import { buildFallbackSvg, buildSvg } from "../diagram/svg";
import { examplePatterns, supportItems } from "./data";

const defaultPattern = "a(b|c)*";

type DiagramResult = {
  svg: string;
  error: string;
};

export const App = () => {
  const [pattern, setPattern] = useState(defaultPattern);
  const result = useDiagramResult(pattern);

  return (
    <main className="mx-auto max-w-[1100px] px-5 py-8 pb-12 font-body text-ink">
      <HeroSection />
      <section className="grid grid-cols-[minmax(260px,1fr)_minmax(360px,1.4fr)] gap-5 max-[900px]:grid-cols-1">
        <InputPanel
          error={result.error}
          pattern={pattern}
          onPatternChange={setPattern}
        />
        <OutputPanel svg={result.svg} />
      </section>
      <SupportSection />
      <CreditFooter />
    </main>
  );
};

const useDiagramResult = (pattern: string): DiagramResult =>
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

const HeroSection = () => (
  <section className="mb-7 grid gap-2.5 rounded border-[3px] border-ink bg-[#ffe1b3] px-5 py-[18px] shadow-brutal-md">
    <h1 className="m-0 text-[34px] font-bold uppercase tracking-normal">
      正規表現ナビ
    </h1>
    <p className="soft-wrap m-0 leading-relaxed text-[#2d2d2d]">
      <span className="soft-chunk">正規表現の構造を</span>
      <wbr />
      <span className="soft-chunk">分かりやすく可視化します。</span>
    </p>
  </section>
);

type InputPanelProps = {
  pattern: string;
  error: string;
  onPatternChange: (pattern: string) => void;
};

const InputPanel = ({ pattern, error, onPatternChange }: InputPanelProps) => (
  <div className="panel max-[900px]:order-2">
    <h2 className="mb-3 mt-0 text-lg font-bold">入力</h2>
    <div className="grid gap-3">
      <input
        className="w-full rounded border-[3px] border-ink bg-[#e6fff6] px-4 py-3.5 font-mono text-base shadow-brutal-sm outline-none focus:border-4 focus:border-accentBlue focus:shadow-brutal"
        placeholder="例: (ab|cd)+"
        type="text"
        value={pattern}
        onChange={(event) => onPatternChange(event.target.value)}
      />
      <ExampleButtons onSelect={onPatternChange} />
      <ErrorMessage message={error} />
    </div>
  </div>
);

type ExampleButtonsProps = {
  onSelect: (pattern: string) => void;
};

const ExampleButtons = ({ onSelect }: ExampleButtonsProps) => (
  <div className="flex flex-wrap gap-2">
    {examplePatterns.map((example) => (
      <button
        className="rounded-sm border-[3px] border-ink bg-[#ffd39a] px-3 py-1.5 text-xs shadow-[3px_3px_0_#151515] transition hover:-translate-x-0.5 hover:-translate-y-0.5 hover:border-accentOrange hover:text-accentOrange hover:shadow-[5px_5px_0_#151515]"
        key={example}
        type="button"
        onClick={() => onSelect(example)}
      >
        {example}
      </button>
    ))}
  </div>
);

type ErrorMessageProps = {
  message: string;
};

const ErrorMessage = ({ message }: ErrorMessageProps) =>
  message.length > 0 ? (
    <div className="mt-2 whitespace-pre-wrap rounded border-[3px] border-ink bg-[#ffe1ec] px-3.5 py-3 text-[13px] shadow-brutal-sm">
      {message}
    </div>
  ) : null;

type OutputPanelProps = {
  svg: string;
};

const OutputPanel = ({ svg }: OutputPanelProps) => {
  const wrapRef = useRef<HTMLDivElement>(null);

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
  });

  return (
    <div className="panel max-[900px]:order-1">
      <h2 className="mb-3 mt-0 text-lg font-bold">出力</h2>
      <div
        className="flex min-h-[260px] w-full items-center justify-start overflow-auto rounded border-[3px] border-dashed border-ink bg-[#f1f6ff] p-4 shadow-brutal-md"
        ref={wrapRef}
      >
        {/* biome-ignore lint/security/noDangerouslySetInnerHtml: SVG markup is generated internally and text is XML-escaped. */}
        <div
          className="flex min-h-full min-w-full flex-[0_0_auto] items-center justify-center"
          dangerouslySetInnerHTML={{ __html: svg }}
        />
      </div>
    </div>
  );
};

const SupportSection = () => (
  <section className="mt-7 rounded border-[3px] border-ink bg-[#fef4d6] p-5 shadow-brutal">
    <h2 className="mb-3.5 mt-0 text-lg font-bold">正規表現ガイド</h2>
    <div className="grid grid-cols-[repeat(auto-fit,minmax(180px,1fr))] gap-3">
      {supportItems.map(([token, parts]) => (
        <SupportCard key={token} parts={parts} token={token} />
      ))}
    </div>
  </section>
);

type SupportCardProps = {
  token: string;
  parts: string[];
};

const SupportCard = ({ token, parts }: SupportCardProps) => (
  <div className="rounded border-[3px] border-ink bg-[#fffdf4] p-3 shadow-brutal-sm">
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
);

const CreditFooter = () => (
  <footer className="mt-7 text-center text-xs text-[#2d2d2d]">
    <p>Developed by 01-mu.</p>
    <div className="mt-2 flex flex-wrap justify-center gap-2.5">
      <a
        className="credit-link credit-link--github"
        href="https://github.com/01-mu/regex-navi"
        rel="noreferrer"
        target="_blank"
      >
        GitHub
      </a>
      <a
        className="credit-link credit-link--x"
        href="https://x.com/01mu_dev"
        rel="noreferrer"
        target="_blank"
      >
        @01mu_dev
      </a>
    </div>
  </footer>
);
