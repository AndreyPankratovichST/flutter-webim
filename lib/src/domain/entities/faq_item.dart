class FAQItem {
  final String id;
  final String question;
  final String answer;

  const FAQItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}
