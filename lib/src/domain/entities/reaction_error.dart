/// Error for react. See ReactionError (Swift).
enum ReactionError implements Exception {
  notAllowed,
  messageNotOwned,
  messageNotFound,
  unknown,
}
