/// Survey events. See MessageStream.set(surveyListener:).
/// Simplified: onSurvey(id), onNextQuestion(), onSurveyCancelled().
abstract class SurveyListener {
  void onSurvey(String surveyId);
  void onNextQuestion();
  void onSurveyCancelled();
}
