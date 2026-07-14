import { useEffect } from "react";
import { Link, useLocation, useNavigate, useParams } from "react-router-dom";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { cacheJobInSession, useJobFromCache, useJobMatch } from "../hooks/useJobs";
import { useIsJobSaved, useSaveJob, useUnsaveJob } from "../hooks/useSavedJobs";
import type { JobPosting } from "../types/job";
import { getErrorMessage } from "../utils/errors";

export function JobDetailPage() {
  const { jobId } = useParams<{ jobId: string }>();
  const location = useLocation();
  const navigate = useNavigate();
  const stateJob = location.state?.job as JobPosting | undefined;

  const { data: job, isLoading, isError, error } = useJobFromCache(jobId);
  const resolvedJob = stateJob ?? job;
  const isSaved = useIsJobSaved(jobId);
  const saveJob = useSaveJob();
  const unsaveJob = useUnsaveJob();
  const jobMatch = useJobMatch();

  useEffect(() => {
    if (resolvedJob && jobId) {
      cacheJobInSession(jobId, resolvedJob);
    }
  }, [resolvedJob, jobId]);

  if (isLoading && !stateJob) {
    return <p className="text-slate-600 dark:text-slate-400">Loading job details...</p>;
  }

  if ((isError || !resolvedJob) && !stateJob) {
    return (
      <div className="space-y-4">
        <Alert message={getErrorMessage(error, "Job not found.")} />
        <Link
          to="/jobs"
          className="text-sm font-medium text-brand-600 hover:text-brand-700 dark:text-accent"
        >
          Back to search
        </Link>
      </div>
    );
  }

  if (!resolvedJob) {
    return null;
  }

  const currentJob = resolvedJob;

  function toggleSaved() {
    if (isSaved) {
      unsaveJob.mutate(currentJob.job_id);
      return;
    }

    saveJob.mutate({
      job_id: currentJob.job_id,
      title: currentJob.title,
      company_name: currentJob.company_name,
      location: currentJob.location,
      description: currentJob.description,
      apply_link: currentJob.apply_link,
      source_platform: currentJob.source_platform,
      posted_date: currentJob.posted_date,
    });
  }

  function scoreResume() {
    jobMatch.mutate(
      { job_id: currentJob.job_id },
      {
        onSuccess: (response) => {
          navigate("/resume", {
            state: {
              matchResult: response.data,
              jobTitle: currentJob.title,
            },
          });
        },
      },
    );
  }

  const posted = currentJob.posted_date
    ? new Date(currentJob.posted_date).toLocaleString()
    : "Unknown";

  return (
    <div className="space-y-6">
      <Link
        to="/jobs"
        className="text-sm font-medium text-brand-600 hover:text-brand-700 dark:text-accent"
      >
        Back to search
      </Link>

      <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-5 shadow-sm sm:p-6 dark:border-border-dark dark:bg-card-dark">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div className="min-w-0 flex-1">
            <h1 className="text-2xl font-bold text-slate-900 sm:text-3xl dark:text-slate-100">
              {currentJob.title}
            </h1>
            <p className="mt-2 text-lg text-slate-600 dark:text-slate-400">{currentJob.company_name}</p>
            <div className="mt-3 flex flex-wrap gap-2 text-sm text-slate-500 dark:text-slate-400">
              <span className="rounded-full bg-slate-100 px-3 py-1 dark:bg-slate-800">{currentJob.location}</span>
              <span className="rounded-full bg-slate-100 px-3 py-1 dark:bg-slate-800">
                {currentJob.source_platform}
              </span>
              <span className="rounded-full bg-slate-100 px-3 py-1 dark:bg-slate-800">{posted}</span>
            </div>
          </div>

          <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">
            <Button
              variant="secondary"
              onClick={toggleSaved}
              loading={saveJob.isPending || unsaveJob.isPending}
              className="w-full sm:w-auto"
            >
              {isSaved ? "Unsave job" : "Save job"}
            </Button>
            <Button onClick={scoreResume} loading={jobMatch.isPending} className="w-full sm:w-auto">
              Score my resume
            </Button>
            {currentJob.apply_link ? (
              <a
                href={currentJob.apply_link}
                target="_blank"
                rel="noreferrer"
                className="btn-lift focus-ring inline-flex min-h-[44px] w-full items-center justify-center rounded-xl bg-brand-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-brand-700 sm:w-auto dark:bg-accent dark:text-slate-900"
              >
                Apply now
              </a>
            ) : null}
          </div>
        </div>

        {jobMatch.isError ? (
          <div className="mt-4">
            <Alert message={getErrorMessage(jobMatch.error, "Could not score resume.")} />
          </div>
        ) : null}

        <div className="mt-8 whitespace-pre-wrap break-words text-sm leading-7 text-slate-700 dark:text-slate-300">
          {currentJob.description || "No description available."}
        </div>
      </div>
    </div>
  );
}
