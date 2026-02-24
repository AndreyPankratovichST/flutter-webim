/// Called when unread by visitor timestamp changes. See MessageStream.set(unreadByVisitorTimestampChangeListener:).
abstract class UnreadByVisitorTimestampChangeListener {
  void changedUnreadByVisitorTimestampTo(DateTime? newValue);
}
