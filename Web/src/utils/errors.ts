import axios from "axios";
import type { AxiosError } from "axios";
import type { ApiErrorBody } from "../types/api";

/** Extract a readable message from backend or network errors. */
export function getErrorMessage(error: unknown, fallback = "Something went wrong."): string {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<ApiErrorBody>;
    const apiMessage = axiosError.response?.data?.error;
    if (apiMessage) {
      return apiMessage;
    }
    if (axiosError.message) {
      return axiosError.message;
    }
  }

  if (error instanceof Error) {
    return error.message;
  }

  return fallback;
}
