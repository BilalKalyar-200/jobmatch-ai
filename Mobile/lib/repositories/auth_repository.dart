import '../core/api/api_client.dart';
import '../../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<TokenResponse> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {'email': email, 'password': password, 'name': name},
    );
    return TokenResponse.fromJson(response.data!);
  }

  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return TokenResponse.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _apiClient.post<void>('/auth/logout', data: {'refresh_token': ''});
  }
}
