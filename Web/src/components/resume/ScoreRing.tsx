interface ScoreRingProps {
  score: number;
  size?: number;
}

/** Circular progress indicator for resume match percentage. */
export function ScoreRing({ score, size = 140 }: ScoreRingProps) {
  const radius = (size - 16) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (score / 100) * circumference;

  return (
    <div
      className="relative inline-flex items-center justify-center"
      style={{ width: size, height: size }}
    >
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          className="stroke-slate-200 dark:stroke-slate-700"
          strokeWidth="10"
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          className="stroke-brand-600 dark:stroke-accent"
          strokeWidth="10"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          strokeLinecap="round"
        />
      </svg>
      <div className="absolute text-center">
        <div className="text-3xl font-bold text-brand-700 dark:text-accent">{Math.round(score)}%</div>
        <div className="text-xs text-slate-500 dark:text-slate-400">Match</div>
      </div>
    </div>
  );
}
