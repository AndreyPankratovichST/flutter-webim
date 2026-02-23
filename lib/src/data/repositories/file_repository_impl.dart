import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/repositories/file_repository.dart';
import '../datasources/api_client.dart';
import 'dart:convert';

class FileRepositoryImpl implements FileRepository {
  final ApiClient _client;

  FileRepositoryImpl(this._client);

  @override
  Future<String> upload(File file, {Map<String, String>? metadata}) async {
    final uri = Uri.parse('${_client.baseUrl}/file/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    if (metadata != null) {
      metadata.forEach((k, v) => request.fields[k] = v);
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return body['url'] as String;
    }
    throw http.ClientException('File upload failed', uri);
  }
}
