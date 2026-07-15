class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.preferredNiches,
    required this.preferredCountries,
    required this.preferredCities,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final List<String> preferredNiches;
  final List<String> preferredCountries;
  final List<String> preferredCities;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      preferredNiches: (json['preferred_niches'] as List<dynamic>? ?? [])
          .cast<String>(),
      preferredCountries: (json['preferred_countries'] as List<dynamic>? ?? [])
          .cast<String>(),
      preferredCities: (json['preferred_cities'] as List<dynamic>? ?? [])
          .cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toUpdateJson({
    String? name,
    List<String>? preferredNiches,
    List<String>? preferredCountries,
    List<String>? preferredCities,
  }) {
    return {
      'name': ?name,
      'preferred_niches': ?preferredNiches,
      'preferred_countries': ?preferredCountries,
      'preferred_cities': ?preferredCities,
    };
  }
}
