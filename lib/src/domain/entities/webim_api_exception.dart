/// Exception for API errors (HTTP 4xx/5xx with error body).
/// Maps server response: { "error": { "code": int, "message": string } } or init/delta { "error": "reinit-required" }.
class WebimApiException implements Exception {
  final int? code;
  final String message;
  final int? statusCode;
  /// Raw response body when available (for typed error parsing).
  final Map<String, dynamic>? body;
  /// Init/delta server error string (e.g. WebimInternalError.reinitializationRequired).
  final String? internalError;

  WebimApiException({
    this.code,
    required this.message,
    this.statusCode,
    this.body,
    this.internalError,
  });

  @override
  String toString() => 'WebimApiException(code: $code, message: $message, statusCode: $statusCode)';
}
