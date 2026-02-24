/// Error for sendSurveyAnswer. See SendSurveyAnswerError (Swift).
enum SendSurveyAnswerError implements Exception {
  incorrectRadioValue,
  incorrectStarsValue,
  incorrectSurveyID,
  maxCommentLength_exceeded,
  noCurrentSurvey,
  questionNotFound,
  surveyDisabled,
  unknown,
}
