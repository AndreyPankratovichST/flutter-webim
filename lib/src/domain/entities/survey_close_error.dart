/// Error for closeSurvey. See SurveyCloseError (Swift).
enum SurveyCloseError implements Exception {
  incorrectSurveyID,
  noCurrentSurvey,
  surveyDisabled,
  unknown,
}
