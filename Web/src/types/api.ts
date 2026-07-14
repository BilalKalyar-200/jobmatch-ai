/** Standard error body returned by the FastAPI backend. */
export interface ApiErrorBody {
  error: string;
  details?: unknown;
}
