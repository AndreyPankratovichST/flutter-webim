/// See DeleteMessageCompletionHandler.onFailure, MessageStream.swift DeleteMessageError.
enum DeleteMessageError implements Exception {
  unknown,
  notAllowed,
  messageNotOwned,
  messageNotFound,
}
