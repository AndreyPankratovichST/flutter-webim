/// Group (message group) on a message. See Message.getGroup(), GroupItem.swift.
class Group {
  const Group({
    required this.id,
    this.messageNumber = 0,
    this.messageCount = 0,
  });

  final String id;
  final int messageNumber;
  final int messageCount;

  static Group? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'] as String?;
    if (id == null) return null;
    return Group(
      id: id,
      messageNumber: json['msg_number'] as int? ?? 0,
      messageCount: json['msg_count'] as int? ?? 0,
    );
  }
}
