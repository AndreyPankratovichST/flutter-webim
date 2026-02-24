/// See SendFileError in MessageStream.swift / ActionRequestLoop.
enum SendFileError implements Exception {
  fileSizeExceeded,
  fileSizeTooSmall,
  fileTypeNotAllowed,
  maxFilesCountPerMessage,
  maxFilesCountPerChatExceeded,
  uploadedFileNotFound,
  unauthorized,
  maliciousFileDetected,
  fileNotFound,
  uploadCanceled,
  unknown,
}
