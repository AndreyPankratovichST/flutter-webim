import '../../../../src/domain/entities/survey_answer.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/api_client.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  final ApiClient _client;

  SurveyRepositoryImpl(this._client);

  @override
  Future<void> submit({
    required String sessionId,
    required String surveyId,
    required List<SurveyAnswer> answers,
  }) async {
    final body = {
      'sessionId': sessionId,
      'surveyId': surveyId,
      'answers': answers
          .map((a) => {'qId': a.questionId, 'answer': a.answer})
          .toList(),
    };
    await _client.post('/survey/submit', body: body);
  }
}
