import 'job_models.dart';

class SavedJobResponse {
  const SavedJobResponse({
    required this.id,
    required this.externalJobId,
    required this.job,
    required this.createdAt,
  });

  final String id;
  final String externalJobId;
  final JobPosting job;
  final DateTime createdAt;

  factory SavedJobResponse.fromJson(Map<String, dynamic> json) {
    return SavedJobResponse(
      id: json['id'] as String,
      externalJobId: json['external_job_id'] as String,
      job: JobPosting.fromJson(json['job'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SavedJobsListResponse {
  const SavedJobsListResponse({required this.total, required this.savedJobs});

  final int total;
  final List<SavedJobResponse> savedJobs;

  factory SavedJobsListResponse.fromJson(Map<String, dynamic> json) {
    return SavedJobsListResponse(
      total: json['total'] as int,
      savedJobs: (json['saved_jobs'] as List<dynamic>)
          .map((item) => SavedJobResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SearchHistoryItem {
  const SearchHistoryItem({
    required this.id,
    required this.niche,
    required this.country,
    required this.cities,
    required this.createdAt,
  });

  final String id;
  final String niche;
  final String country;
  final List<String> cities;
  final DateTime createdAt;

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'] as String,
      niche: json['niche'] as String,
      country: json['country'] as String,
      cities: (json['cities'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SearchHistoryListResponse {
  const SearchHistoryListResponse({required this.total, required this.searches});

  final int total;
  final List<SearchHistoryItem> searches;

  factory SearchHistoryListResponse.fromJson(Map<String, dynamic> json) {
    return SearchHistoryListResponse(
      total: json['total'] as int,
      searches: (json['searches'] as List<dynamic>)
          .map((item) => SearchHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
