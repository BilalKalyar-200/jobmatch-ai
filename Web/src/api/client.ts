import axios, { type AxiosError, type InternalAxiosRequestConfig } from "axios";
import { useAuthStore } from "../store/authStore";
import type { TokenResponse } from "../types/auth";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://127.0.0.1:8000";
const API_PREFIX = "/api/v1";

export const apiClient = axios.create({
  baseURL: `${API_BASE_URL}${API_PREFIX}`,
  headers: {
    "Content-Type": "application/json",
  },
});

/** Tracks refresh in progress so parallel 401s wait for one refresh call. */
let isRefreshing = false;
let refreshQueue: Array<(token: string | null) => void> = [];

function processRefreshQueue(token: string | null) {
  refreshQueue.forEach((callback) => callback(token));
  refreshQueue = [];
}

function attachAccessToken(config: InternalAxiosRequestConfig) {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}

async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = useAuthStore.getState().refreshToken;
  if (!refreshToken) {
    return null;
  }

  // Refresh uses a plain axios call to avoid interceptor recursion.
  const response = await axios.post<TokenResponse>(
    `${API_BASE_URL}${API_PREFIX}/auth/refresh`,
    { refresh_token: refreshToken },
  );

  const { access_token, refresh_token } = response.data;
  useAuthStore.getState().setTokens(access_token, refresh_token);
  return access_token;
}

apiClient.interceptors.request.use(attachAccessToken);

apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    if (error.response?.status !== 401 || !originalRequest || originalRequest._retry) {
      return Promise.reject(error);
    }

    // Do not attempt refresh for auth endpoints themselves.
    if (originalRequest.url?.includes("/auth/login") || originalRequest.url?.includes("/auth/signup")) {
      return Promise.reject(error);
    }

    if (isRefreshing) {
      return new Promise((resolve, reject) => {
        refreshQueue.push((token) => {
          if (!token) {
            reject(error);
            return;
          }
          originalRequest.headers.Authorization = `Bearer ${token}`;
          resolve(apiClient(originalRequest));
        });
      });
    }

    originalRequest._retry = true;
    isRefreshing = true;

    try {
      const newToken = await refreshAccessToken();
      processRefreshQueue(newToken);

      if (!newToken) {
        useAuthStore.getState().clearAuth();
        return Promise.reject(error);
      }

      originalRequest.headers.Authorization = `Bearer ${newToken}`;
      return apiClient(originalRequest);
    } catch (refreshError) {
      processRefreshQueue(null);
      useAuthStore.getState().clearAuth();
      return Promise.reject(refreshError);
    } finally {
      isRefreshing = false;
    }
  },
);

export { API_BASE_URL, API_PREFIX };
