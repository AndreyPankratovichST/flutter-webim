/// Image metadata for uploaded file. See UploadedFile.getImageInfo(), ImageInfo in Swift.
abstract class ImageInfo {
  int? get width;
  int? get height;
  String? get thumbUrl;
}
