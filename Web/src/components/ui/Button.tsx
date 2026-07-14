import type { ButtonHTMLAttributes, ReactNode } from "react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  variant?: "primary" | "secondary" | "ghost" | "danger";
  loading?: boolean;
}

const variants = {
  primary:
    "bg-brand-600 text-white hover:bg-brand-700 disabled:bg-brand-300 dark:bg-accent dark:text-slate-900 dark:hover:brightness-110 dark:disabled:opacity-50",
  secondary:
    "border border-slate-300 bg-surface-elevated text-slate-700 hover:bg-slate-50 dark:border-border-dark dark:bg-card-dark dark:text-slate-200 dark:hover:bg-slate-800",
  ghost: "text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800",
  danger:
    "bg-red-600 text-white hover:bg-red-700 disabled:bg-red-300 dark:bg-red-700 dark:hover:bg-red-600",
};

export function Button({
  children,
  variant = "primary",
  loading = false,
  disabled,
  className = "",
  ...props
}: ButtonProps) {
  return (
    <button
      type="button"
      disabled={disabled || loading}
      className={`btn-lift focus-ring inline-flex min-h-[44px] items-center justify-center rounded-xl px-4 py-2.5 text-sm font-medium disabled:cursor-not-allowed ${variants[variant]} ${className}`}
      {...props}
    >
      {loading ? "Please wait..." : children}
    </button>
  );
}
