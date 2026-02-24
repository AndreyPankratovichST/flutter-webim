/// See EditMessageCompletionHandler.onFailure, MessageStream.swift EditMessageError.
enum EditMessageError implements Exception {
  unknown,
  notAllowed,
  messageEmpty,
  messageNotOwned,
  maxLengthExceeded,
  wrongMessageKind,
}
