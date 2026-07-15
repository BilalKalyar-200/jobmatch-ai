import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/api_config.dart';
import '../../models/auth_models.dart';
import '../auth/auth_session.dart';
import '../storage/token_storage.dart';
import '../utils/error_parser.dart';

typedef TokenRefreshCallback = Future<void> Function();

/// Central Dio client with JWT attachment and queued token refresh on 401.
class ApiClient {
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
    : _tokenStorage = tokenStorage,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _attachAccessToken, onError: _handleError),
    );
  }

  final TokenStorage _tokenStorage;
  final Dio _dio;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];

  Dio get dio => _dio;

  Future<void> _attachAccessToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    final requestOptions = error.requestOptions;

    if (response?.statusCode != 401 || requestOptions.extra['_retry'] == true) {
      handler.next(_wrapError(error));
      return;
    }

    final path = requestOptions.path;
    if (path.contains('/auth/login') || path.contains('/auth/signup')) {
      handler.next(_wrapError(error));
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      final newToken = await completer.future;
      if (newToken == null) {
        handler.reject(_wrapError(error));
        return;
      }
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final retryResponse = await _dio.fetch(requestOptions);
        handler.resolve(retryResponse);
      } on DioException catch (retryError) {
        handler.reject(_wrapError(retryError));
      }
      return;
    }

    _isRefreshing = true;
    requestOptions.extra['_retry'] = true;

    try {
      final newToken = await _refreshAccessToken();
      _completeRefreshQueue(newToken);

      if (newToken == null) {
        await AuthSession.onForceLogout?.call();
        handler.reject(_wrapError(error));
        return;
      }

      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await _dio.fetch(requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      _completeRefreshQueue(null);
      await AuthSession.onForceLogout?.call();
      handler.reject(_wrapError(error));
    } finally {
      _isRefreshing = false;
    }
  }

  void _completeRefreshQueue(String? token) {
    for (final completer in _refreshQueue) {
      completer.complete(token);
    }
    _refreshQueue.clear();
  }

  /// Uses a plain Dio call to avoid interceptor recursion during refresh.
  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final refreshDio = Dio(BaseOptions(baseUrl: ApiConfig.apiBaseUrl));
    final response = await refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final tokenResponse = TokenResponse.fromJson(response.data!);
    await _tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );
    return tokenResponse.accessToken;
  }

  DioException _wrapError(DioException error) {
    final response = error.response;
    final data = response?.data;
    final message = parseApiErrorMessage(data);
    final details = data is Map<String, dynamic> ? data['details'] : null;

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ApiException(
        message,
        statusCode: response?.statusCode,
        details: details,
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Options? options}) {
    return _dio.post<T>(path, data: data, options: options);
  }

  Future<Response<T>> patch<T>(String path, {Map<String, dynamic>? data}) {
    return _dio.patch<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }

  /// Multipart upload helper used by resume upload.
  Future<Response<T>> postMultipart<T>(String path, FormData formData) {
    return _dio.post<T>(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}

ApiException apiExceptionFrom(
  dynamic error, {
  String fallback = 'Request failed.',
}) {
  if (error is DioException && error.error is ApiException) {
    return error.error as ApiException;
  }
  if (error is ApiException) {
    return error;
  }
  return ApiException(fallback);
}

String readableErrorMessage(
  dynamic error, {
  String fallback = 'Request failed.',
}) {
  final apiError = apiExceptionFrom(error, fallback: fallback);
  final detailsText = parseValidationDetails(apiError.details);
  if (detailsText.isNotEmpty) {
    return detailsText;
  }
  return apiError.message.isNotEmpty ? apiError.message : fallback;
}

void debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
