/// Chat state as seen by an operator.
/// See MessageStream.getChatState(), ChatStateListener.
enum ChatState {
  /// Operator has taken the chat for processing.
  chatting,

  /// Chat is picked up by a bot.
  chattingWithRobot,

  /// Operator has closed the chat.
  closedByOperator,

  /// Visitor has closed the chat.
  closedByVisitor,

  /// Chat started by operator, waiting for visitor response.
  invitation,

  /// No chat (not started by visitor or operator).
  closed,

  /// Chat started by visitor, in queue for operator.
  queue,

  /// State undefined (initial or unsupported).
  unknown,
}

/// Online state possible cases.
/// See OnlineStatusChangeListener.
enum OnlineStatus {
  /// Offline with chats' count limit exceeded.
  busyOffline,

  /// Online with chats' count limit exceeded.
  busyOnline,

  /// Visitor can send offline messages.
  offline,

  /// Visitor can send both online and offline messages.
  online,

  /// First status not received yet or not supported.
  unknown,
}
