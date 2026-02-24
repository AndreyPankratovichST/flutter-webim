/// Operator (id, name, avatar, title, info).
/// See MessageStream.getCurrentOperator(), OperatorImpl/OperatorItem.
abstract class Operator {
  String get id;
  String get name;
  String? get avatarUrl;
  String? get title;
  String? get info;
}

/// Implementation from server JSON.
/// OperatorItem: id (Int), fullname, avatar, additionalInfo, title.
class OperatorImpl implements Operator {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarUrl;
  @override
  final String? title;
  @override
  final String? info;

  const OperatorImpl({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.title,
    this.info,
  });

  static OperatorImpl? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'];
    final fullName = json['fullname'] as String?;
    if (id == null || fullName == null) return null;
    return OperatorImpl(
      id: id is int ? id.toString() : id as String,
      name: fullName,
      avatarUrl: json['avatar'] as String?,
      title: json['title'] as String?,
      info: json['additionalInfo'] as String?,
    );
  }
}
