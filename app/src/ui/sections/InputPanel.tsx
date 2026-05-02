import { examplePatterns } from "../data";

type InputPanelProps = {
  pattern: string;
  error: string;
  onPatternChange: (pattern: string) => void;
};

export const InputPanel = ({
  pattern,
  error,
  onPatternChange,
}: InputPanelProps) => (
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
