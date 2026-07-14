import { useState, type InputHTMLAttributes } from "react";
import { EyeIcon, EyeOffIcon } from "./Icons";

interface PasswordInputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, "type"> {
  label: string;
  error?: string;
}

export function PasswordInput({ label, error, id, className = "", ...props }: PasswordInputProps) {
  const inputId = id ?? props.name;
  const [visible, setVisible] = useState(false);

  return (
    <div className="space-y-1">
      <label
        htmlFor={inputId}
        className="block text-sm font-medium text-slate-700 dark:text-slate-300"
      >
        {label}
      </label>
      <div className="relative">
        <input
          id={inputId}
          type={visible ? "text" : "password"}
          className={`focus-ring w-full rounded-xl border bg-surface-elevated px-3 py-3 pr-11 text-sm outline-none transition dark:bg-card-dark dark:text-slate-100 ${
            error ? "border-red-300 dark:border-red-700" : "border-slate-300 dark:border-border-dark"
          } focus:border-brand-500 dark:focus:border-accent ${className}`}
          {...props}
        />
        <button
          type="button"
          onClick={() => setVisible((current) => !current)}
          className="focus-ring absolute right-1 top-1/2 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-lg text-slate-500 transition hover:text-slate-700 dark:text-slate-400 dark:hover:text-accent"
          aria-label={visible ? "Hide password" : "Show password"}
        >
          {visible ? <EyeOffIcon /> : <EyeIcon />}
        </button>
      </div>
      {error ? <p className="text-xs text-red-600 dark:text-red-400">{error}</p> : null}
    </div>
  );
}
