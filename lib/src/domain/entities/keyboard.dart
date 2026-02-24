import 'package:webim/src/domain/entities/keyboard_button.dart';

/// Keyboard with buttons. See Message.getKeyboard(), KeyboardItem.swift.
class Keyboard {
  const Keyboard({this.buttons = const [], this.state});

  final List<List<KeyboardButton>> buttons;
  final String? state;

  static Keyboard? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final buttonsJson = json['buttons'] as List<dynamic>?;
    List<List<KeyboardButton>> rows = [];
    if (buttonsJson != null) {
      for (final row in buttonsJson) {
        if (row is! List) continue;
        rows.add(
          row
              .map((e) => KeyboardButton.fromJson(e is Map ? Map<String, dynamic>.from(e) : null))
              .whereType<KeyboardButton>()
              .toList(),
        );
      }
    }
    return Keyboard(
      buttons: rows,
      state: json['state'] as String?,
    );
  }
}
