import { supportItems } from "../data";

export const SupportSection = () => (
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
