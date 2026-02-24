/// Quote (replied message) on a message. See Message.getQuote(), QuoteItem.swift.
class Quote {
  const Quote({
    this.messageId,
    this.state,
    this.authorId,
    this.text,
    this.senderName,
    this.timestamp,
  });

  final String? messageId;
  final String? state; // pending, filled, not-found
  final String? authorId;
  final String? text;
  final String? senderName;
  final DateTime? timestamp;

  static Quote? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final message = json['message'] as Map<String, dynamic>?;
    if (message == null) return null;
    final ts = message['ts'] as num?;
    return Quote(
      messageId: message['id'] as String?,
      state: json['state'] as String?,
      authorId: (message['authorId'] as num?)?.toString(),
      text: message['text'] as String?,
      senderName: message['name'] as String?,
      timestamp: ts != null ? DateTime.fromMillisecondsSinceEpoch((ts * 1000).round()) : null,
    );
  }
}
