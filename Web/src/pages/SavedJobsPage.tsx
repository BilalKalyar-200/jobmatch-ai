import { Link } from "react-router-dom";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { EmptyState } from "../components/ui/EmptyState";
import { SearchEmptyIcon } from "../components/ui/Icons";
import { useSavedJobs, useUnsaveJob } from "../hooks/useSavedJobs";
import { getErrorMessage } from "../utils/errors";

export function SavedJobsPage() {
  const { data, isLoading, isError, error } = useSavedJobs();
  const unsaveJob = useUnsaveJob();

  if (isLoading) {
    return <p className="text-slate-600 dark:text-slate-400">Loading saved jobs...</p>;
  }

  if (isError) {
    return <Alert message={getErrorMessage(error, "Could not load saved jobs.")} />;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 sm:text-3xl dark:text-slate-100">Saved jobs</h1>
        <p className="mt-2 text-slate-600 dark:text-slate-400">Jobs you bookmarked from search results.</p>
      </div>

      {data && data.total === 0 ? (
        <EmptyState
          icon={<SearchEmptyIcon />}
          title="No saved jobs yet"
          description="Save jobs from the search or detail pages to review them here later."
          action={
            <Link
              to="/jobs"
              className="focus-ring btn-lift inline-flex min-h-[44px] items-center rounded-xl bg-brand-600 px-4 py-2.5 text-sm font-medium text-white dark:bg-accent dark:text-slate-900"
            >
              Go to job search
            </Link>
          }
        />
      ) : null}

      <div className="space-y-4">
        {data?.saved_jobs.map((saved) => (
          <div
            key={saved.id}
            className="card-hover flex flex-col gap-4 rounded-2xl border border-slate-200 bg-surface-elevated p-5 shadow-sm sm:flex-row sm:items-center sm:justify-between dark:border-border-dark dark:bg-card-dark"
          >
            <div className="min-w-0">
              <Link
                to={`/jobs/${encodeURIComponent(saved.job.job_id)}`}
                state={{ job: saved.job }}
                className="text-lg font-semibold text-slate-900 hover:text-brand-700 dark:text-slate-100 dark:hover:text-accent"
              >
                {saved.job.title}
              </Link>
              <p className="text-sm text-slate-600 dark:text-slate-400">{saved.job.company_name}</p>
              <p className="mt-1 text-xs text-slate-500">{saved.job.location}</p>
            </div>
            <Button
              variant="danger"
              onClick={() => unsaveJob.mutate(saved.external_job_id)}
              loading={unsaveJob.isPending}
              className="w-full sm:w-auto"
            >
              Remove
            </Button>
          </div>
        ))}
      </div>
    </div>
  );
}
