import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { savedApi } from "../api/saved";
import type { SaveJobRequest } from "../types/saved";

export function useSavedJobs() {
  return useQuery({
    queryKey: ["savedJobs"],
    queryFn: async () => {
      const response = await savedApi.listSavedJobs();
      return response.data;
    },
  });
}

export function useSaveJob() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (payload: SaveJobRequest) => savedApi.saveJob(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["savedJobs"] });
    },
  });
}

export function useUnsaveJob() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (jobId: string) => savedApi.unsaveJob(jobId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["savedJobs"] });
    },
  });
}

export function useSearchHistory() {
  return useQuery({
    queryKey: ["searchHistory"],
    queryFn: async () => {
      const response = await savedApi.listSearchHistory();
      return response.data;
    },
  });
}

export function useDeleteSearchHistory() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (searchId: string) => savedApi.deleteSearchHistory(searchId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["searchHistory"] });
    },
  });
}

export function useIsJobSaved(jobId: string | undefined) {
  const { data } = useSavedJobs();
  if (!jobId || !data) {
    return false;
  }
  return data.saved_jobs.some((saved) => saved.external_job_id === jobId);
}
