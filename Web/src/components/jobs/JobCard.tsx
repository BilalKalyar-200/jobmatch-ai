import { Link } from "react-router-dom";
import type { JobPosting } from "../../types/job";

interface JobCardProps {
  job: JobPosting;
}

export function JobCard({ job }: JobCardProps) {
  const posted = job.posted_date
    ? new Date(job.posted_date).toLocaleDateString(undefined, {
        year: "numeric",
        month: "short",
        day: "numeric",
      })
    : "Date unavailable";

  return (
    <Link
      to={`/jobs/${encodeURIComponent(job.job_id)}`}
      state={{ job }}
      className="card-hover focus-ring block rounded-2xl border border-slate-200 bg-surface-elevated p-5 shadow-sm dark:border-border-dark dark:bg-card-dark dark:hover:border-accent/40"
    >
      <div className="space-y-3">
        <div>
          <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-100">{job.title}</h3>
          <p className="text-sm font-medium text-slate-600 dark:text-slate-400">{job.company_name}</p>
        </div>
        <div className="flex flex-wrap gap-2 text-xs text-slate-500 dark:text-slate-400">
          <span className="rounded-full bg-slate-100 px-2.5 py-1 dark:bg-slate-800">{job.location}</span>
          <span className="rounded-full bg-slate-100 px-2.5 py-1 dark:bg-slate-800">{job.source_platform}</span>
          <span className="rounded-full bg-slate-100 px-2.5 py-1 dark:bg-slate-800">{posted}</span>
        </div>
      </div>
    </Link>
  );
}
