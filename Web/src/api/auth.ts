import { apiClient } from "./client";
import type {
  LoginRequest,
  MessageResponse,
  RefreshRequest,
  SignupRequest,
  TokenResponse,
} from "../types/auth";

export const authApi = {
  signup(payload: SignupRequest) {
    return apiClient.post<TokenResponse>("/auth/signup", payload);
  },

  login(payload: LoginRequest) {
    return apiClient.post<TokenResponse>("/auth/login", payload);
  },

  refresh(payload: RefreshRequest) {
    return apiClient.post<TokenResponse>("/auth/refresh", payload);
  },

  logout(payload: RefreshRequest) {
    return apiClient.post<MessageResponse>("/auth/logout", payload);
  },
};
