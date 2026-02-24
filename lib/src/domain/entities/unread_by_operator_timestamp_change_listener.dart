/// Called when unread by operator timestamp changes. See MessageStream.set(unreadByOperatorTimestampChangeListener:).
abstract class UnreadByOperatorTimestampChangeListener {
  void changedUnreadByOperatorTimestampTo(DateTime? newValue);
}
