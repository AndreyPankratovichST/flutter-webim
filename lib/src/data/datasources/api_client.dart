import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:webim/src/domain/entities/webim_api_exception.dart';

/// Low-level HTTP client for the SDK.
/// Supports Bearer token and parses server error body.
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authorizationToken;
  Map<String, String> _extraHeaders = {};

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  void setAuthorizationToken(String? token) {
    _authorizationToken = token;
  }

  void setRequestHeader(String key, String value) {
    _extraHeaders[key] = value;
  }

  void setRequestHeaders(Map<String, String> headers) {
    _extraHeaders.addAll(headers);
  }

  Map<String, String> get _headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      ..._extraHeaders,
    };
    if (_authorizationToken != null && _authorizationToken!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_authorizationToken';
    }
    return map;
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path');
    final response = await _client.post(uri,
        headers: {..._headers, if (headers != null) ...headers},
        body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? headers, Map<String, dynamic>? query}) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path')
        .replace(queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));
    final response = await _client.get(uri,
        headers: {..._headers, if (headers != null) ...headers});
    return _handleResponse(response);
  }

  /// GET to full URL with optional query (e.g. action endpoint /l/v/file-delete?guid=...).
  Future<Map<String, dynamic>> getFullUrl(String fullUrl,
      {Map<String, String>? queryParameters}) async {
    var uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
          queryParameters: queryParameters.map((k, v) => MapEntry(k, v)));
    }
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path');
    final response = await _client.delete(uri,
        headers: {..._headers, if (headers != null) ...headers});
    return _handleResponse(response);
  }

  /// POST multipart to full URL (e.g. /l/v/m/upload) with file and optional fields.
  Future<Map<String, dynamic>> postMultipart(
    String fullUrl,
    Map<String, String> fields,
    List<int> fileBytes,
    String fileFieldName,
    String fileName,
    String mimeType,
  ) async {
    final uri = Uri.parse(fullUrl);
    final request = http.MultipartRequest('POST', uri);
    if (_authorizationToken != null && _authorizationToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_authorizationToken';
    }
    request.headers.addAll(_extraHeaders);
    for (final e in fields.entries) {
      request.fields[e.key] = e.value;
    }
    request.files.add(http.MultipartFile.fromBytes(
      fileFieldName,
      fileBytes is Uint8List ? fileBytes : Uint8List.fromList(fileBytes),
      filename: fileName,
    ));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// POST JSON to full URL without Authorization (e.g. external autocomplete URL).
  Future<Map<String, dynamic>> postToUrlNoAuth(String fullUrl, Map<String, dynamic> body) async {
    final uri = Uri.parse(fullUrl);
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', ..._extraHeaders},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// POST form-urlencoded body to full URL (e.g. action endpoint).
  Future<Map<String, dynamic>> postForm(String fullUrl, Map<String, String> body) async {
    final uri = Uri.parse(fullUrl);
    final encoded = body.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        if (_authorizationToken != null && _authorizationToken!.isNotEmpty)
          'Authorization': 'Bearer $_authorizationToken',
        ..._extraHeaders,
      },
      body: encoded,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final body = response.body;
      if (body.isEmpty) return {};
      return jsonDecode(body) as Map<String, dynamic>;
    }
    int? code;
    String message = 'HTTP $status';
    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        body = Map<String, dynamic>.from(decoded);
        final err = body['error'];
        if (err is Map) {
          code = err['code'] as int?;
          message = err['message'] as String? ?? message;
        }
      }
    } catch (_) {}
    throw WebimApiException(code: code, message: message, statusCode: status, body: body);
  }
}
