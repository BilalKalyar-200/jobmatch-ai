import { useCallback, useState, type DragEvent } from "react";

interface ResumeDropzoneProps {
  onFileSelected: (file: File) => void;
  disabled?: boolean;
}

const ACCEPTED = ".pdf,.docx,application/pdf,application/vnd.openxmlformats-officedocument.wordprocessingml.document";

export function ResumeDropzone({ onFileSelected, disabled = false }: ResumeDropzoneProps) {
  const [isDragging, setIsDragging] = useState(false);

  const handleFile = useCallback(
    (file: File | undefined) => {
      if (!file || disabled) {
        return;
      }
      onFileSelected(file);
    },
    [disabled, onFileSelected],
  );

  function onDrop(event: DragEvent<HTMLDivElement>) {
    event.preventDefault();
    setIsDragging(false);
    handleFile(event.dataTransfer.files?.[0]);
  }

  return (
    <div
      onDragOver={(event) => {
        event.preventDefault();
        setIsDragging(true);
      }}
      onDragLeave={() => setIsDragging(false)}
      onDrop={onDrop}
      className={`rounded-2xl border-2 border-dashed p-6 text-center transition sm:p-8 ${
        isDragging
          ? "border-brand-500 bg-brand-50 dark:border-accent dark:bg-accent/10"
          : "border-slate-300 bg-surface-elevated dark:border-border-dark dark:bg-card-dark"
      } ${disabled ? "opacity-60" : ""}`}
    >
      <p className="text-sm font-medium text-slate-700 dark:text-slate-200">
        Drag and drop your resume here
      </p>
      <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">PDF or DOCX, up to 5 MB</p>
      <label className="btn-lift focus-ring mt-4 inline-flex min-h-[44px] cursor-pointer items-center rounded-xl bg-brand-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-brand-700 dark:bg-accent dark:text-slate-900">
        Choose file
        <input
          type="file"
          accept={ACCEPTED}
          className="hidden"
          disabled={disabled}
          onChange={(event) => handleFile(event.target.files?.[0])}
        />
      </label>
    </div>
  );
}
