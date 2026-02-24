/// Error for sendKeyboardRequest. See KeyboardResponseError (Swift).
enum KeyboardResponseError implements Exception {
  unknown,
  noChat,
  buttonIdNotSet,
  requestMessageIdNotSet,
  canNotCreateResponse,
}
