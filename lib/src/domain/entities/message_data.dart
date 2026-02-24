/// Message data (attachment, translation, etc.). See Message.getData(), MessageDataItem.swift.
/// Holds raw map for file/translation_info; full parsing can be extended.
class MessageData {
  const MessageData({this.raw});

  final Map<String, dynamic>? raw;

  static MessageData? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    return MessageData(raw: Map<String, dynamic>.from(json));
  }
}
