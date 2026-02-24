/// Error types that can be thrown by MessageStream / WebimSession methods.
/// See WebimSession.swift AccessError.
enum AccessError implements Exception {
  /// Method was called not from the thread the WebimSession was created in.
  /// In Dart this is not enforced (no main-thread requirement like in Swift).
  invalidThread,

  /// WebimSession was destroyed; further calls throw this.
  invalidSession,
}
