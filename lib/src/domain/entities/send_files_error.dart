/// Error for sendUploadedFiles. See SendFilesError (Swift).
enum SendFilesError implements Exception {
  fileNotFound,
  maxFilesCountPerMessage,
  unknown,
}
