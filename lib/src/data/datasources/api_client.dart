import 'dart:convert';
import 'package:http/http.dart' as http;

/// Low‑level HTTP client for the SDK.
class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path');
    final response = await _client.post(uri,
        headers: {
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        },
        body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? headers, Map<String, dynamic>? query}) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path')
        .replace(queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));
    final response = await _client.get(uri,
        headers: {
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        });
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path');
    final response = await _client.delete(uri,
        headers: {
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        });
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    // Simplified error handling – in production map to custom errors
    throw http.ClientException('HTTP $status', response.request?.url);
  }
}
