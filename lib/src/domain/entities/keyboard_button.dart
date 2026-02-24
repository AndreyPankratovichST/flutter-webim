/// Single keyboard button. See Keyboard.getButtons(), KeyboardButton in Swift.
class KeyboardButton {
  const KeyboardButton({required this.id, this.text});

  final String id;
  final String? text;

  static KeyboardButton? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'] as String?;
    if (id == null) return null;
    return KeyboardButton(id: id, text: json['text'] as String?);
  }
}
