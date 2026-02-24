import 'package:webim/src/domain/entities/autocomplete_error.dart';
import 'package:webim/src/domain/entities/data_message_error.dart';
import 'package:webim/src/domain/entities/geolocation_error.dart';
import 'package:webim/src/domain/entities/send_survey_answer_error.dart';
import 'package:webim/src/domain/entities/survey_close_error.dart';
import 'package:webim/src/domain/entities/webim_api_exception.dart';

/// Context for typed error parsing. Only errors of this type are returned.
enum ActionErrorContext {
  dataMessage,
  autocomplete,
  geolocation,
  surveyAnswer,
  surveyClose,
}

/// Parses WebimApiException into typed domain errors when backend returns known error codes/strings.
/// [context] limits which error type to return. Returns null if no mapping found (caller should rethrow original).
Exception? parseActionError(WebimApiException e, [ActionErrorContext? context]) {
  final msg = e.message.toLowerCase();
  final body = e.body;
  final errorString = body?['error'] is Map
      ? (body!['error'] as Map)['string']?.toString().toLowerCase() ??
          (body['error'] as Map)['message']?.toString().toLowerCase()
      : null;
  final s = (errorString ?? msg);

  if (context == null || context == ActionErrorContext.dataMessage) {
    if (s.contains('quoted_message_can_not_be_replied') ||
        s.contains('quotedmessagecannotbereplied')) {
      return DataMessageError.quotedMessageCanNotBeReplied;
    }
    if (s.contains('quoted_message_from_another_visitor')) {
      return DataMessageError.quotedMessageFromAnotherVisitor;
    }
    if (s.contains('quoted_message_multiple_ids')) {
      return DataMessageError.quotedMessageMultipleIds;
    }
    if (s.contains('quoted_message_required_arguments_missing')) {
      return DataMessageError.quotedMessageRequiredArgumentsMissing;
    }
    if (s.contains('quoted_message_wrong_id')) {
      return DataMessageError.quotedMessageWrongId;
    }
  }

  if (context == null || context == ActionErrorContext.autocomplete) {
    if (s.contains('hint_api_invalid') || s.contains('hintapiinvalid')) {
      return AutocompleteError.hintApiInvalid;
    }
  }

  if (context == null || context == ActionErrorContext.geolocation) {
    if (s.contains('invalid_geolocation') || s.contains('invalidgeolocation')) {
      return GeolocationError.invalidGeolocation;
    }
  }

  if (context == null || context == ActionErrorContext.surveyAnswer) {
    if (s.contains('incorrect_radio_value')) return SendSurveyAnswerError.incorrectRadioValue;
    if (s.contains('incorrect_stars_value')) return SendSurveyAnswerError.incorrectStarsValue;
    if (s.contains('incorrect_survey_id')) return SendSurveyAnswerError.incorrectSurveyID;
    if (s.contains('max_comment_length') || s.contains('maxcommentlength')) {
      return SendSurveyAnswerError.maxCommentLength_exceeded;
    }
    if (s.contains('no_current_survey')) return SendSurveyAnswerError.noCurrentSurvey;
    if (s.contains('question_not_found')) return SendSurveyAnswerError.questionNotFound;
    if (s.contains('survey_disabled')) return SendSurveyAnswerError.surveyDisabled;
  }

  if (context == null || context == ActionErrorContext.surveyClose) {
    if (s.contains('incorrect_survey_id')) return SurveyCloseError.incorrectSurveyID;
    if (s.contains('no_current_survey')) return SurveyCloseError.noCurrentSurvey;
    if (s.contains('survey_disabled')) return SurveyCloseError.surveyDisabled;
  }

  return null;
}
