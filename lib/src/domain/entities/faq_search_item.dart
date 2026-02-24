/// FAQ search result item (id, title, score). See FAQSearchItem (Swift), FAQSearchItemItem.
class FAQSearchItem {
  const FAQSearchItem({
    required this.id,
    this.title = '',
    this.score = -1.0,
  });

  final String id;
  final String title;
  final double score;

  /// JSON: id, title, score. See FAQSearchItemItem.
  static FAQSearchItem fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title'] as String? ?? '';
    final score = (json['score'] is num) ? (json['score'] as num).toDouble() : -1.0;
    return FAQSearchItem(id: id, title: title, score: score);
  }
}
