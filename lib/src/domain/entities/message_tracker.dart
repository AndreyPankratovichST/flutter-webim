import 'package:webim/src/domain/entities/access_error.dart';
import 'package:webim/src/domain/entities/message.dart';

/// Tracker for message history. See MessageTracker.swift.
/// After [destroy], methods throw [AccessError.invalidSession].
abstract class MessageTracker {
  void getLastMessages(int limit, void Function(List<Message>) completion);
  void getNextMessages(int limit, void Function(List<Message>) completion);
  void getAllMessages(void Function(List<Message>) completion);
  void resetTo(Message message);
  void destroy();
}
