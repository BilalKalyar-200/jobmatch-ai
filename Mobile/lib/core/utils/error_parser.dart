/// Parsed backend error payload: {"error": "...", "details": ...}
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() => message;
}

String parseApiErrorMessage(dynamic data, {String fallback = 'Request failed.'}) {
  if (data is Map<String, dynamic>) {
    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
  }
  return fallback;
}

String parseValidationDetails(dynamic details) {
  if (details is! List) {
    return '';
  }

  final messages = <String>[];
  for (final item in details) {
    if (item is Map<String, dynamic>) {
      final message = item['msg'];
      if (message is String && message.isNotEmpty) {
        messages.add(message);
      }
    }
  }

  return messages.join(' ');
}
