import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { JobCard } from "../components/jobs/JobCard";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { EmptyState } from "../components/ui/EmptyState";
import { SearchEmptyIcon } from "../components/ui/Icons";
import { useProfile } from "../hooks/useAuth";
import { useCacheSearchResults, useJobSearch } from "../hooks/useJobs";
import { getCountryName } from "../utils/countries";
import { getErrorMessage } from "../utils/errors";

export function JobSearchPage() {
  const { data: profile, isLoading: profileLoading } = useProfile();
  const jobSearch = useJobSearch();
  const { setResults, getResults } = useCacheSearchResults();
  const [results, setLocalResults] = useState(getResults());
  const [hasSearched, setHasSearched] = useState(Boolean(getResults()));

  useEffect(() => {
    const cached = getResults();
    if (cached) {
      setLocalResults(cached);
      setHasSearched(true);
    }
  }, [getResults]);

  const niche = profile?.preferred_niches[0] ?? "";
  const country = profile?.preferred_countries[0] ?? "";
  const cities = profile?.preferred_cities ?? [];

  function runSearch() {
    if (!niche || !country || cities.length === 0) {
      return;
    }

    setHasSearched(true);
    jobSearch.mutate(
      {
        niche,
        country: country.toLowerCase(),
        cities,
      },
      {
        onSuccess: (response) => {
          setResults(response.data);
          setLocalResults(response.data);
        },
      },
    );
  }

  if (profileLoading) {
    return <p className="text-slate-600 dark:text-slate-400">Loading your profile...</p>;
  }

  const needsPreferences = !niche || !country || cities.length === 0;
  const showInitialEmpty = !hasSearched && !jobSearch.isPending && !needsPreferences;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 sm:text-3xl dark:text-slate-100">Job search</h1>
          <p className="mt-2 text-slate-600 dark:text-slate-400">
            {needsPreferences
              ? "Set your preferences before searching."
              : `Searching for ${niche} in ${cities.join(", ")}, ${getCountryName(country)}.`}
          </p>
        </div>
        <div className="flex flex-col gap-2 sm:flex-row">
          <Link
            to="/preferences"
            className="focus-ring btn-lift inline-flex min-h-[44px] items-center justify-center rounded-xl border border-slate-300 px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:bg-slate-50 dark:border-border-dark dark:text-slate-200 dark:hover:bg-slate-800"
          >
            Edit preferences
          </Link>
          <Button onClick={runSearch} loading={jobSearch.isPending} disabled={needsPreferences}>
            Search jobs
          </Button>
        </div>
      </div>

      {needsPreferences ? (
        <Alert
          message="Add a niche, country, and at least one city on the preferences page."
          variant="info"
        />
      ) : null}

      {jobSearch.isError ? (
        <Alert message={getErrorMessage(jobSearch.error, "Job search failed.")} />
      ) : null}

      {jobSearch.isPending ? (
        <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-10 text-center text-slate-600 dark:border-border-dark dark:bg-card-dark dark:text-slate-400">
          Searching live job postings...
        </div>
      ) : null}

      {showInitialEmpty ? (
        <EmptyState
          icon={<SearchEmptyIcon />}
          title="Ready to find your next role"
          description="Your preferences are set. Run a search to see live job postings matched to your niche and cities."
          action={
            <Button onClick={runSearch} loading={jobSearch.isPending}>
              Search jobs now
            </Button>
          }
        />
      ) : null}

      {!jobSearch.isPending && hasSearched && results && results.total === 0 ? (
        <EmptyState
          icon={<SearchEmptyIcon />}
          title="No jobs found"
          description="Try different cities or broaden your niche on the preferences page."
          action={
            <Link
              to="/preferences"
              className="focus-ring btn-lift inline-flex min-h-[44px] items-center rounded-xl bg-brand-600 px-4 py-2.5 text-sm font-medium text-white dark:bg-accent dark:text-slate-900"
            >
              Update preferences
            </Link>
          }
        />
      ) : null}

      {!jobSearch.isPending && results && results.total > 0 ? (
        <div className="space-y-4">
          <p className="text-sm text-slate-600 dark:text-slate-400">
            Found {results.total} jobs{results.cached ? " (cached results)" : ""}.
          </p>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            {results.jobs.map((job) => (
              <JobCard key={job.job_id} job={job} />
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}
