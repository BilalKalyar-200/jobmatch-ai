import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { authApi } from "../api/auth";
import { userApi } from "../api/users";
import { useAuthStore } from "../store/authStore";
import type { LoginRequest, SignupRequest } from "../types/auth";

export function useProfile() {
  return useQuery({
    queryKey: ["profile"],
    queryFn: async () => {
      const response = await userApi.getProfile();
      return response.data;
    },
    enabled: useAuthStore.getState().isAuthenticated(),
  });
}

export function useLogin() {
  const navigate = useNavigate();
  const setTokens = useAuthStore((state) => state.setTokens);
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (payload: LoginRequest) => authApi.login(payload),
    onSuccess: async (response) => {
      setTokens(response.data.access_token, response.data.refresh_token);
      await queryClient.invalidateQueries({ queryKey: ["profile"] });
      navigate("/jobs");
    },
  });
}

export function useSignup() {
  const navigate = useNavigate();
  const setTokens = useAuthStore((state) => state.setTokens);
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (payload: SignupRequest) => authApi.signup(payload),
    onSuccess: async (response) => {
      setTokens(response.data.access_token, response.data.refresh_token);
      await queryClient.invalidateQueries({ queryKey: ["profile"] });
      navigate("/preferences");
    },
  });
}

export function useLogout() {
  const navigate = useNavigate();
  const refreshToken = useAuthStore((state) => state.refreshToken);
  const clearAuth = useAuthStore((state) => state.clearAuth);
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      if (refreshToken) {
        await authApi.logout({ refresh_token: refreshToken });
      }
    },
    onSettled: () => {
      clearAuth();
      queryClient.clear();
      navigate("/login");
    },
  });
}

export function useUpdateProfile() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: userApi.updateProfile,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["profile"] });
    },
  });
}
