/// Breaks the ApiClient and AuthNotifier circular dependency for forced logout.
class AuthSession {
  static Future<void> Function()? onForceLogout;
}
