class JobPosting {
  const JobPosting({
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.location,
    required this.description,
    required this.applyLink,
    required this.sourcePlatform,
    this.postedDate,
  });

  final String jobId;
  final String title;
  final String companyName;
  final String location;
  final String description;
  final String applyLink;
  final String sourcePlatform;
  final String? postedDate;

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      jobId: json['job_id'] as String,
      title: json['title'] as String,
      companyName: json['company_name'] as String,
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      applyLink: json['apply_link'] as String? ?? '',
      sourcePlatform: json['source_platform'] as String? ?? '',
      postedDate: json['posted_date'] as String?,
    );
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'job_id': jobId,
      'title': title,
      'company_name': companyName,
      'location': location,
      'description': description,
      'apply_link': applyLink,
      'source_platform': sourcePlatform,
      'posted_date': postedDate,
    };
  }
}

class JobSearchResponse {
  const JobSearchResponse({
    required this.total,
    required this.jobs,
    required this.cached,
  });

  final int total;
  final List<JobPosting> jobs;
  final bool cached;

  factory JobSearchResponse.fromJson(Map<String, dynamic> json) {
    return JobSearchResponse(
      total: json['total'] as int,
      jobs: (json['jobs'] as List<dynamic>)
          .map((item) => JobPosting.fromJson(item as Map<String, dynamic>))
          .toList(),
      cached: json['cached'] as bool? ?? false,
    );
  }
}

class JobMatchResponse {
  const JobMatchResponse({
    required this.finalScore,
    required this.keywordScore,
    required this.semanticScore,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.scoringFormula,
  });

  final double finalScore;
  final double keywordScore;
  final double semanticScore;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final String scoringFormula;

  factory JobMatchResponse.fromJson(Map<String, dynamic> json) {
    return JobMatchResponse(
      finalScore: (json['final_score'] as num).toDouble(),
      keywordScore: (json['keyword_score'] as num).toDouble(),
      semanticScore: (json['semantic_score'] as num).toDouble(),
      matchedKeywords: (json['matched_keywords'] as List<dynamic>? ?? []).cast<String>(),
      missingKeywords: (json['missing_keywords'] as List<dynamic>? ?? []).cast<String>(),
      scoringFormula: json['scoring_formula'] as String,
    );
  }
}
