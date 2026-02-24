/// Called when operator typing state changes. See MessageStream.set(operatorTypingListener:).
abstract class OperatorTypingListener {
  void onOperatorTypingStateChanged(bool isTyping);
}
