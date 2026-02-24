import 'package:webim/src/domain/entities/keyboard_button.dart';

/// Keyboard request (response requested). See Message.getKeyboardRequest(), KeyboardRequestItem.
class KeyboardRequest {
  const KeyboardRequest({required this.messageId, this.button});

  final String messageId;
  final KeyboardButton? button;

  static KeyboardRequest? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final messageId = json['messageId'] as String? ?? json['request_message_id'] as String?;
    if (messageId == null) return null;
    final button = json['button'] is Map ? KeyboardButton.fromJson(Map<String, dynamic>.from(json['button'] as Map)) : null;
    return KeyboardRequest(messageId: messageId, button: button);
  }
}
