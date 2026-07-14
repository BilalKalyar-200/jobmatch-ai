export interface ResumeResponse {
  id: string;
  filename: string;
  text_preview: string;
  created_at: string;
  updated_at: string;
}

export interface ResumeUploadResponse {
  resume: ResumeResponse;
  message: string;
}
