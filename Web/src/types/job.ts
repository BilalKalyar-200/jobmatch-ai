export interface JobPosting {
  job_id: string;
  title: string;
  company_name: string;
  location: string;
  description: string;
  apply_link: string;
  source_platform: string;
  posted_date: string | null;
}

export interface JobSearchRequest {
  niche: string;
  country: string;
  cities: string[];
}

export interface JobSearchResponse {
  total: number;
  jobs: JobPosting[];
  cached: boolean;
}

export interface JobMatchRequest {
  job_id?: string | null;
  job_description?: string | null;
}

export interface JobMatchResponse {
  final_score: number;
  keyword_score: number;
  semantic_score: number;
  matched_keywords: string[];
  missing_keywords: string[];
  scoring_formula: string;
}
