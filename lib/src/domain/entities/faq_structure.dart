import 'package:webim/src/domain/entities/root_type.dart';

/// FAQ category subtree (id, type, children, title). See FAQStructure (Swift), FAQStructureItem.
class FAQStructure {
  const FAQStructure({
    required this.id,
    required this.type,
    this.children = const [],
    this.title = '',
  });

  final String id;
  final RootType type;
  final List<FAQStructure> children;
  final String title;

  /// JSON: id (String or int), type ("category"|"item"), childs (array), title. See FAQStructureItem.swift.
  static FAQStructure? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final typeRaw = json['type'] as String?;
    final rootType = _parseType(typeRaw);
    final id = _parseId(json['id'], rootType);
    final title = json['title'] as String? ?? '';
    final childs = json['childs'] as List<dynamic>?;
    final children = <FAQStructure>[];
    if (childs != null) {
      for (final c in childs) {
        if (c is Map) {
          final child = fromJson(Map<String, dynamic>.from(c));
          if (child != null) children.add(child);
        }
      }
    }
    return FAQStructure(
      id: id,
      type: rootType,
      children: children,
      title: title,
    );
  }

  static RootType _parseType(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'item':
        return RootType.item;
      case 'category':
        return RootType.category;
      default:
        return RootType.unknown;
    }
  }

  static String _parseId(dynamic value, RootType type) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    return '';
  }
}
