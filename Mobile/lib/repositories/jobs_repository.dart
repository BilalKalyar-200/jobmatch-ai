import '../core/api/api_client.dart';
import '../models/job_models.dart';

class JobsRepository {
  JobsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<JobSearchResponse> searchJobs({
    required String niche,
    required String country,
    required List<String> cities,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/jobs/search',
      data: {
        'niche': niche,
        'country': country.toLowerCase(),
        'cities': cities,
      },
    );
    return JobSearchResponse.fromJson(response.data!);
  }

  Future<JobMatchResponse> matchJob({
    String? jobId,
    String? jobDescription,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/jobs/match',
      data: {'job_id': ?jobId, 'job_description': ?jobDescription},
    );
    return JobMatchResponse.fromJson(response.data!);
  }
}
