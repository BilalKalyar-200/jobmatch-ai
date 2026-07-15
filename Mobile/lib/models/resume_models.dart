class ResumeResponse {
  const ResumeResponse({
    required this.id,
    required this.filename,
    required this.textPreview,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String filename;
  final String textPreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ResumeResponse.fromJson(Map<String, dynamic> json) {
    return ResumeResponse(
      id: json['id'] as String,
      filename: json['filename'] as String,
      textPreview: json['text_preview'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ResumeUploadResponse {
  const ResumeUploadResponse({required this.resume, required this.message});

  final ResumeResponse resume;
  final String message;

  factory ResumeUploadResponse.fromJson(Map<String, dynamic> json) {
    return ResumeUploadResponse(
      resume: ResumeResponse.fromJson(json['resume'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }
}
