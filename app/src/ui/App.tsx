import { useState } from "react";
import { useDiagramResult } from "./hooks/useDiagramResult";
import { CreditFooter } from "./sections/CreditFooter";
import { HeroSection } from "./sections/HeroSection";
import { InputPanel } from "./sections/InputPanel";
import { OutputPanel } from "./sections/OutputPanel";
import { SupportSection } from "./sections/SupportSection";

const defaultPattern = "a(b|c)*";

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
