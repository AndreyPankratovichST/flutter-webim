import 'package:webim/src/domain/entities/image_info.dart';

/// Uploaded file. See UploadedFile.swift.
abstract class UploadedFile {
  /// JSON-like description used when sending multiple files (Swift description).
  String get description;

  int get size;
  String get guid;
  String get fileName;
  String? get contentType;
  String get visitorID;
  String get clientContentType;
  ImageInfo? get imageInfo;
}
