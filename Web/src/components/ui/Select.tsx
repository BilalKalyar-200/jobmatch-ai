import type { SelectHTMLAttributes } from "react";

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label: string;
  options: Array<{ label: string; value: string }>;
}

export function Select({ label, options, id, className = "", ...props }: SelectProps) {
  const selectId = id ?? props.name;

  return (
    <div className="space-y-1">
      <label
        htmlFor={selectId}
        className="block text-sm font-medium text-slate-700 dark:text-slate-300"
      >
        {label}
      </label>
      <select
        id={selectId}
        className={`focus-ring w-full rounded-xl border border-slate-300 bg-surface-elevated px-3 py-3 text-sm outline-none transition dark:border-border-dark dark:bg-card-dark dark:text-slate-100 focus:border-brand-500 dark:focus:border-accent ${className}`}
        {...props}
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  );
}
