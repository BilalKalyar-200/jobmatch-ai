import { apiClient } from "./client";
import type {
  JobMatchRequest,
  JobMatchResponse,
  JobSearchRequest,
  JobSearchResponse,
} from "../types/job";

export const jobsApi = {
  search(payload: JobSearchRequest) {
    return apiClient.post<JobSearchResponse>("/jobs/search", payload);
  },

  match(payload: JobMatchRequest) {
    return apiClient.post<JobMatchResponse>("/jobs/match", payload);
  },
};
