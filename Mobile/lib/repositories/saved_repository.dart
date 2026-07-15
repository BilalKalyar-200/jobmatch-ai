import '../core/api/api_client.dart';
import '../models/job_models.dart';
import '../models/saved_models.dart';

class SavedRepository {
  SavedRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SavedJobsListResponse> listSavedJobs() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/saved/jobs');
    return SavedJobsListResponse.fromJson(response.data!);
  }

  Future<SavedJobResponse> saveJob(JobPosting job) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/saved/jobs',
      data: job.toSaveJson(),
    );
    return SavedJobResponse.fromJson(response.data!);
  }

  Future<void> unsaveJob(String jobId) async {
    await _apiClient.delete<void>('/saved/jobs/$jobId');
  }

  Future<SearchHistoryListResponse> listSearchHistory() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/saved/searches');
    return SearchHistoryListResponse.fromJson(response.data!);
  }

  Future<void> deleteSearchHistory(String searchId) async {
    await _apiClient.delete<void>('/saved/searches/$searchId');
  }
}
