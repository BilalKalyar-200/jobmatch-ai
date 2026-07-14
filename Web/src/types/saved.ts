import type { JobPosting } from "./job";

export interface SaveJobRequest {
  job_id: string;
  title: string;
  company_name: string;
  location: string;
  description: string;
  apply_link: string;
  source_platform: string;
  posted_date: string | null;
}

export interface SavedJobResponse {
  id: string;
  external_job_id: string;
  job: JobPosting;
  created_at: string;
}

export interface SavedJobsListResponse {
  total: number;
  saved_jobs: SavedJobResponse[];
}

export interface SearchHistoryItem {
  id: string;
  niche: string;
  country: string;
  cities: string[];
  created_at: string;
}

export interface SearchHistoryListResponse {
  total: number;
  searches: SearchHistoryItem[];
}
