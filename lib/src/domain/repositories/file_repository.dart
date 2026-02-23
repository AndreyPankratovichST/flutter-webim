import 'dart:io';

/// Repository for file upload.
abstract class FileRepository {
  /// Uploads a [file] with optional [metadata]. Returns the signed URL.
  Future<String> upload(File file, {Map<String, String>? metadata});
}
