import 'package:webim/src/domain/entities/uploaded_file.dart';

/// Repository for SDK actions (startChat, closeChat, send, edit, delete, reply, etc.).
/// Sends form-urlencoded POST to action endpoint (Swift: /l/v/m/action).
abstract class ActionRepository {
  Future<void> startChat({
    required String clientSideId,
    String? firstQuestion,
    String? departmentKey,
    String? customFields,
    bool forceStart = false,
  });

  Future<void> closeChat();
  Future<void> setVisitorTyping({
    required bool typing,
    String? draft,
    bool deleteDraft = false,
  });
  Future<void> setPrechatFields(String prechatFields);

  /// Send text message (action chat.message). For edit, use same with existing clientSideId.
  /// [data] optional custom data (DataMessage).
  Future<void> sendMessage({
    required String clientSideId,
    required String message,
    bool isHintQuestion = false,
    Map<String, dynamic>? data,
  });

  /// Reply with quote (action chat.message + quote).
  Future<void> replyMessage({
    required String clientSideId,
    required String message,
    required String quotedMessageId,
  });

  /// Delete message (action chat.delete_message).
  Future<void> deleteMessage(String clientSideId);

  /// Upload file (multipart POST to /l/v/m/upload). Returns uploaded file params.
  Future<UploadedFile> uploadFile(
    List<int> fileBytes,
    String filename,
    String mimeType,
    String clientSideId,
  );

  /// Send message with kind file_visitor (message is JSON array of file descriptions).
  Future<void> sendFiles(String message, String clientSideId);

  /// Delete uploaded file (GET /l/v/file-delete?guid=...).
  Future<void> deleteUploadedFile(String fileGuid);

  /// Send sticker (action sticker).
  Future<void> sendSticker(int stickerId, String clientSideId);

  /// Rate operator (action chat.operator_rate_select). Rating 1..5 sent as (rating - 3) = -2..2.
  Future<void> rateOperator({String? operatorId, required int rating, String? note, int? threadId});

  /// Resolution survey (action chat.resolution_survey_select). Answer 0 or 1.
  Future<void> sendResolutionSurvey({required String operatorId, required int answer, int? threadId});

  /// Respond to sentry call (action chat.action_request.call_sentry_action_request). [id] is message id.
  Future<void> respondSentryCall(String id);

  /// Set chat/message read (action chat.read_by_visitor). Optional [messageId] for message-level read.
  Future<void> setChatRead({String? messageId});

  /// Send chat history to email (action chat.send_chat_history).
  Future<void> sendDialogToEmail(String emailAddress);

  /// Survey: send answer (action survey.answer).
  Future<void> sendSurveyAnswer({
    required String surveyId,
    required String formId,
    required String questionId,
    required String answer,
  });

  /// Survey: close (action survey.cancel).
  Future<void> closeSurvey(String surveyId);

  /// Send geolocation (action geo response).
  Future<void> sendGeolocation(double latitude, double longitude);

  /// Update widget status (action widget update).
  Future<void> updateWidgetStatus(String data);

  /// Keyboard response (action chat.keyboard_response).
  Future<void> sendKeyboardRequest({required String buttonId, required String requestMessageId});

  /// React to message (action chat.react_message). [reaction] is 'like' or 'dislike'.
  Future<void> sendReaction(String clientSideId, String reaction);

  /// Search messages. Returns raw response (data.items = list of message JSON).
  Future<Map<String, dynamic>> searchMessages(String query);

  /// Clear chat history (action chat.clear_history).
  Future<void> clearHistory();

  /// GET raw config for location.
  Future<Map<String, dynamic>> getRawConfig(String location);

  /// GET server-side settings.
  Future<Map<String, dynamic>> getServerSideSettings();

  /// Autocomplete: POST body to external [url]. No auth.
  Future<List<String>> autocomplete(String text, String url);
}
