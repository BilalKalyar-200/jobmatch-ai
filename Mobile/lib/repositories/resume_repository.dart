import 'dart:io';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../models/resume_models.dart';

class ResumeRepository {
  ResumeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ResumeUploadResponse> uploadResume(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _apiClient.postMultipart<Map<String, dynamic>>(
      '/resumes/upload',
      formData,
    );
    return ResumeUploadResponse.fromJson(response.data!);
  }

  Future<ResumeResponse> getMyResume() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/resumes/me');
    return ResumeResponse.fromJson(response.data!);
  }
}
