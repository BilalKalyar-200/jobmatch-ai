import { formatResumePreviewForDisplay } from "../../utils/resumePreview";

interface ResumePreviewTextProps {
  text: string;
}

/** Read-only resume preview with display formatting only. */
export function ResumePreviewText({ text }: ResumePreviewTextProps) {
  const displayText = formatResumePreviewForDisplay(text);

  return (
    <div className="mt-3 max-w-3xl rounded-xl border border-slate-200 bg-slate-50/80 p-4 dark:border-border-dark dark:bg-surface-dark/80">
      <p className="whitespace-pre-wrap break-words text-sm leading-7 text-slate-700 dark:text-slate-300">
        {displayText}
      </p>
    </div>
  );
}
