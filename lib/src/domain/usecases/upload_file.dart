import '../repositories/file_repository.dart';
import 'dart:io';

class UploadFile {
  final FileRepository _repo;

  const UploadFile(this._repo);

  Future<String> call(File file, {Map<String, String>? metadata}) =>
      _repo.upload(file, metadata: metadata);
}
