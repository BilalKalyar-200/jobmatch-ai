import { apiClient } from "./client";
import type { ResumeResponse, ResumeUploadResponse } from "../types/resume";

export const resumesApi = {
  upload(file: File) {
    const formData = new FormData();
    formData.append("file", file);

    return apiClient.post<ResumeUploadResponse>("/resumes/upload", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
  },

  getMine() {
    return apiClient.get<ResumeResponse>("/resumes/me");
  },
};
