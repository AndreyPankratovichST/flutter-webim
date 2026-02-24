/// Sticker on a message. See Message.getSticker(), StickerItem.swift.
class Sticker {
  const Sticker({required this.stickerId});

  final int stickerId;

  static Sticker? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['stickerId'] as int?;
    if (id == null) return null;
    return Sticker(stickerId: id);
  }
}
