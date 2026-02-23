class SurveyAnswer {
  const SurveyAnswer({required this.questionId, required this.answer});

  final String questionId;
  final String answer;

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      questionId: json['questionId'].toString(),
      answer: json['answer'].toString(),
    );
  }
}
