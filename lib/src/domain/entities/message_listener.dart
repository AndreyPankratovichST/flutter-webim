import 'package:webim/src/domain/entities/message.dart';

/// Listener for message stream changes. See MessageListener.swift.
abstract class MessageListener {
  void added(Message newMessage, [Message? after]);
  void removed(Message message);
  void removedAllMessages();
  void changed(Message oldVersion, Message newVersion);
}
