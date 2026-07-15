import '../core/api/api_client.dart';
import '../models/user_profile.dart';

class UserRepository {
  UserRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/users/me');
    return UserProfile.fromJson(response.data!);
  }

  Future<UserProfile> updateProfile({
    String? name,
    List<String>? preferredNiches,
    List<String>? preferredCountries,
    List<String>? preferredCities,
  }) async {
    final payload = <String, dynamic>{
      'name': ?name,
      'preferred_niches': ?preferredNiches,
      'preferred_countries': ?preferredCountries,
      'preferred_cities': ?preferredCities,
    };

    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/users/me',
      data: payload,
    );
    return UserProfile.fromJson(response.data!);
  }
}
