import 'package:webim/src/domain/entities/image_info.dart';
import 'package:webim/src/domain/entities/uploaded_file.dart';

/// Implementation built from server response (FileParametersItem JSON).
class UploadedFileImpl implements UploadedFile {
  UploadedFileImpl({
    required this.size,
    required this.guid,
    required this.fileName,
    this.contentType,
    required this.visitorID,
    required this.clientContentType,
    this.imageInfo,
  });

  @override
  final int size;
  @override
  final String guid;
  @override
  final String fileName;
  @override
  final String? contentType;
  @override
  final String visitorID;
  @override
  final String clientContentType;
  @override
  final ImageInfo? imageInfo;

  @override
  String get description {
    final imagePart = imageInfo != null
        ? ',"image":{"size":{"width":${imageInfo!.width ?? 0},"height":${imageInfo!.height ?? 0}}}'
        : '';
    return '{"client_content_type":"$clientContentType",'
        '"visitor_id":"$visitorID",'
        '"filename":"$fileName",'
        '"content_type":"${contentType ?? ""}",'
        '"guid":"$guid"'
        '$imagePart'
        ',"size":$size}';
  }

  static UploadedFileImpl fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    ImageInfo? imageInfo;
    if (image != null) {
      final sizeObj = image['size'] as Map<String, dynamic>?;
      if (sizeObj != null) {
        imageInfo = ImageInfoImpl(
          width: (sizeObj['width'] as num?)?.toInt(),
          height: (sizeObj['height'] as num?)?.toInt(),
        );
      }
    }
    return UploadedFileImpl(
      size: (json['size'] as num?)?.toInt() ?? 0,
      guid: json['guid'] as String? ?? '',
      fileName: json['filename'] as String? ?? '',
      contentType: json['content_type'] as String?,
      visitorID: json['visitor_id'] as String? ?? '',
      clientContentType: json['client_content_type'] as String? ?? '',
      imageInfo: imageInfo,
    );
  }
}

class ImageInfoImpl implements ImageInfo {
  ImageInfoImpl({this.width, this.height, this.thumbUrl});

  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? thumbUrl;
}
