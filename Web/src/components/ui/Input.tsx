import type { InputHTMLAttributes } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export function Input({ label, error, id, className = "", ...props }: InputProps) {
  const inputId = id ?? props.name;

  return (
    <div className="space-y-1">
      <label
        htmlFor={inputId}
        className="block text-sm font-medium text-slate-700 dark:text-slate-300"
      >
        {label}
      </label>
      <input
        id={inputId}
        className={`focus-ring w-full rounded-xl border bg-surface-elevated px-3 py-3 text-sm outline-none transition dark:bg-card-dark dark:text-slate-100 ${
          error ? "border-red-300 dark:border-red-700" : "border-slate-300 dark:border-border-dark"
        } focus:border-brand-500 dark:focus:border-accent ${className}`}
        {...props}
      />
      {error ? <p className="text-xs text-red-600 dark:text-red-400">{error}</p> : null}
    </div>
  );
}
