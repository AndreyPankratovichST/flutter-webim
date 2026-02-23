import '../../../../src/domain/entities/survey_answer.dart';

/// Repository for survey operations.
abstract class SurveyRepository {
  /// Submits a set of answers for a given survey.
  Future<void> submit({required String sessionId, required String surveyId, required List<SurveyAnswer> answers});
}
