import { apiClient } from "./client";
import type { UserProfileResponse, UserProfileUpdateRequest } from "../types/user";

export const userApi = {
  getProfile() {
    return apiClient.get<UserProfileResponse>("/users/me");
  },

  updateProfile(payload: UserProfileUpdateRequest) {
    return apiClient.patch<UserProfileResponse>("/users/me", payload);
  },
};
