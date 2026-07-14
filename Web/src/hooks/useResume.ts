import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { resumesApi } from "../api/resumes";

export function useMyResume() {
  return useQuery({
    queryKey: ["myResume"],
    queryFn: async () => {
      const response = await resumesApi.getMine();
      return response.data;
    },
    retry: false,
  });
}

export function useUploadResume() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (file: File) => resumesApi.upload(file),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["myResume"] });
    },
  });
}
