import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { jobsApi } from "../api/jobs";
import type { JobPosting, JobSearchRequest } from "../types/job";

export function useJobSearch() {
  return useMutation({
    mutationFn: (payload: JobSearchRequest) => jobsApi.search(payload),
  });
}

export function useJobMatch() {
  return useMutation({
    mutationFn: jobsApi.match,
  });
}

export function useCacheSearchResults() {
  const queryClient = useQueryClient();

  return {
    setResults: (data: Awaited<ReturnType<typeof jobsApi.search>>["data"]) => {
      queryClient.setQueryData(["lastJobSearch"], data);
    },
    getResults: () => queryClient.getQueryData<Awaited<ReturnType<typeof jobsApi.search>>["data"]>([
      "lastJobSearch",
    ]),
  };
}

export function useJobFromCache(jobId: string | undefined) {
  const queryClient = useQueryClient();

  return useQuery({
    queryKey: ["jobDetail", jobId],
    queryFn: (): JobPosting => {
      const cachedSearch = queryClient.getQueryData<{ jobs: JobPosting[] }>(["lastJobSearch"]);
      const fromSearch = cachedSearch?.jobs.find((job) => job.job_id === jobId);
      if (fromSearch) {
        return fromSearch;
      }

      const stored = sessionStorage.getItem(`job:${jobId}`);
      if (stored) {
        return JSON.parse(stored) as JobPosting;
      }

      throw new Error("Job not found. Return to search and open the job again.");
    },
    enabled: Boolean(jobId),
  });
}

export function cacheJobInSession(jobId: string, job: unknown) {
  sessionStorage.setItem(`job:${jobId}`, JSON.stringify(job));
}
