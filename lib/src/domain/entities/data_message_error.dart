/// Error for send(message, data:) DataMessage. See DataMessageError (Swift).
enum DataMessageError implements Exception {
  unknown,
  quotedMessageCanNotBeReplied,
  quotedMessageFromAnotherVisitor,
  quotedMessageMultipleIds,
  quotedMessageRequiredArgumentsMissing,
  quotedMessageWrongId,
}
