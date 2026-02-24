/// Called when unread by visitor message count changes. See MessageStream.set(unreadByVisitorMessageCountChangeListener:).
abstract class UnreadByVisitorMessageCountChangeListener {
  void changedUnreadByVisitorMessageCountTo(int newValue);
}
