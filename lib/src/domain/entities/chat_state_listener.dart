import 'package:webim/src/domain/entities/chat_state.dart';

/// Called when chat state changes. See MessageStream.set(chatStateListener:).
abstract class ChatStateListener {
  void changed(ChatState previous, ChatState newState);
}
