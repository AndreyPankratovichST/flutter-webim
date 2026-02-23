import '../repositories/survey_repository.dart';
import '../../../../src/domain/entities/survey_answer.dart';

class SubmitSurvey {
  final SurveyRepository _repo;

  const SubmitSurvey(this._repo);

  Future<void> call({required String sessionId, required String surveyId, required List<SurveyAnswer> answers}) =>
      _repo.submit(sessionId: sessionId, surveyId: surveyId, answers: answers);
}
