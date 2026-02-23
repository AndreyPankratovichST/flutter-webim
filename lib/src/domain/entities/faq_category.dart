import 'package:webim/src/domain/entities/faq_item.dart';

class FAQCategory {
  final String id;
  final String title;
  final List<FAQItem> items;

  const FAQCategory({required this.id, required this.title, required this.items});

  factory FAQCategory.fromJson(Map<String, dynamic> json) {
    return FAQCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => FAQItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
