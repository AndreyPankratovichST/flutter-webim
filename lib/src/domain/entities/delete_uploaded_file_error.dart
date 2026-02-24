/// See DeleteUploadedFileError in MessageStream.swift.
enum DeleteUploadedFileError implements Exception {
  fileNotFound,
  fileHasBeenSent,
  unknown,
}
