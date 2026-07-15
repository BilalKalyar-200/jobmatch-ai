import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/token_storage.dart';
import '../models/auth_models.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'app_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.profile,
  });

  final AuthStatus status;
  final UserProfile? profile;

  AuthState copyWith({AuthStatus? status, UserProfile? profile}) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._tokenStorage,
    this._authRepository,
    this._ref,
  ) : super(const AuthState(status: AuthStatus.unknown));

  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  final Ref _ref;

  Future<void> bootstrap() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final profile = await _ref.read(userRepositoryProvider).getProfile();
      state = AuthState(status: AuthStatus.authenticated, profile: profile);
    } catch (_) {
      await _tokenStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final tokens = await _authRepository.login(email: email, password: password);
    await _persistTokens(tokens);
    final profile = await _ref.read(userRepositoryProvider).getProfile();
    state = AuthState(status: AuthStatus.authenticated, profile: profile);
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final tokens = await _authRepository.signup(
      email: email,
      password: password,
      name: name,
    );
    await _persistTokens(tokens);
    final profile = await _ref.read(userRepositoryProvider).getProfile();
    state = AuthState(status: AuthStatus.authenticated, profile: profile);
  }

  Future<void> refreshProfile() async {
    if (state.status != AuthStatus.authenticated) {
      return;
    }
    final profile = await _ref.read(userRepositoryProvider).getProfile();
    state = state.copyWith(profile: profile);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _ref.read(apiClientProvider).post<void>(
          '/auth/logout',
          data: {'refresh_token': refreshToken},
        );
      } catch (_) {
        // Ignore logout network errors, still clear local tokens.
      }
    }
    await forceLogout();
  }

  Future<void> forceLogout() async {
    await _tokenStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _persistTokens(TokenResponse tokens) async {
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(tokenStorageProvider),
    ref.watch(authRepositoryProvider),
    ref,
  );
});
