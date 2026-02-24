/// Session possible states.
/// See MessageStream.getVisitSessionState(), VisitSessionStateListener.
enum VisitSessionState {
  /// Chat in progress.
  chat,

  /// Chat must be started with department selected.
  departmentSelection,

  /// Session is active but no chat is occurring (chat was not started yet).
  idle,

  /// Session is active but no chat is occurring (chat was closed recently).
  idleAfterChat,

  /// Offline state.
  offlineMessage,

  /// First status is not received yet or status is not supported.
  unknown,

  /// First question state.
  firstQuestion,
}
