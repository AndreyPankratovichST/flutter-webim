/// Called when hello message is received. See MessageStream.set(helloMessageListener:).
abstract class HelloMessageListener {
  void helloMessage(String message);
}
