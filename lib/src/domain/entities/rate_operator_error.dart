/// Error for rateOperator. See RateOperatorError (Swift).
enum RateOperatorError implements Exception {
  noChat,
  wrongOperatorId,
  noteIsTooLong,
  rateDisabled,
  operatorNotInChat,
  rateValueIncorrect,
  unknown,
}
