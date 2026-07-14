import { apiClient } from "./client";
import type {
  SaveJobRequest,
  SavedJobResponse,
  SavedJobsListResponse,
  SearchHistoryListResponse,
} from "../types/saved";
import type { MessageResponse } from "../types/auth";

export const savedApi = {
  saveJob(payload: SaveJobRequest) {
    return apiClient.post<SavedJobResponse>("/saved/jobs", payload);
  },

  unsaveJob(jobId: string) {
    return apiClient.delete<MessageResponse>(`/saved/jobs/${encodeURIComponent(jobId)}`);
  },

  listSavedJobs() {
    return apiClient.get<SavedJobsListResponse>("/saved/jobs");
  },

  listSearchHistory() {
    return apiClient.get<SearchHistoryListResponse>("/saved/searches");
  },

  deleteSearchHistory(searchId: string) {
    return apiClient.delete(`/saved/searches/${encodeURIComponent(searchId)}`);
  },
};
