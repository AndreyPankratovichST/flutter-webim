import 'package:webim/src/domain/entities/chat_state.dart';

/// Called when online status changes. See MessageStream.set(onlineStatusChangeListener:).
abstract class OnlineStatusChangeListener {
  void changed(OnlineStatus previous, OnlineStatus newStatus);
}
