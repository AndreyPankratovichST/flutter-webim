/// Error for sendResolutionSurvey. See SendResolutionError (Swift).
enum SendResolutionError implements Exception {
  noChat,
  rateDisabled,
  operatorNotInChat,
  resolutionSurveyValueIncorrect,
  unknown,
  rateFormMismatch,
  visitorSegmentMismatch,
  ratedEntityMismatch,
}
