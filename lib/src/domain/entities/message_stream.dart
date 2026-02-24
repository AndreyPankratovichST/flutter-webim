import 'package:webim/src/domain/entities/chat_state.dart';
import 'package:webim/src/domain/entities/chat_state_listener.dart';
import 'package:webim/src/domain/entities/current_operator_change_listener.dart';
import 'package:webim/src/domain/entities/department.dart';
import 'package:webim/src/domain/entities/department_list_change_listener.dart';
import 'package:webim/src/domain/entities/hello_message_listener.dart';
import 'package:webim/src/domain/entities/location_settings.dart';
import 'package:webim/src/domain/entities/location_settings_change_listener.dart';
import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/entities/message_listener.dart';
import 'package:webim/src/domain/entities/message_tracker.dart';
import 'package:webim/src/domain/entities/operator.dart';
import 'package:webim/src/domain/entities/operator_typing_listener.dart';
import 'package:webim/src/domain/entities/online_status_change_listener.dart';
import 'package:webim/src/domain/entities/session_language_listener.dart';
import 'package:webim/src/domain/entities/survey_listener.dart';
import 'package:webim/src/domain/entities/unread_by_operator_timestamp_change_listener.dart';
import 'package:webim/src/domain/entities/unread_by_visitor_message_count_change_listener.dart';
import 'package:webim/src/domain/entities/unread_by_visitor_timestamp_change_listener.dart';
import 'package:webim/src/domain/entities/uploaded_file.dart';
import 'package:webim/src/domain/entities/visit_session_state.dart';
import 'package:webim/src/domain/entities/visit_session_state_listener.dart';

/// Message stream attached to a session. See MessageStream.swift.
abstract class MessageStream {
  VisitSessionState getVisitSessionState();
  ChatState getChatState();
  int? getChatId();
  DateTime? getUnreadByOperatorTimestamp();
  DateTime? getUnreadByVisitorTimestamp();
  int getUnreadByVisitorMessageCount();
  List<Department>? getDepartmentList();
  LocationSettings getLocationSettings();
  Operator? getCurrentOperator();
  String? getChatLanguage();
  int getLastRatingOfOperatorWith(String id);
  int? getLastResolutionSurveyWith(String operatorId);

  void startChat({String? firstQuestion, String? departmentKey, String? customFields, bool forceStart = false});
  void forceStartChat({String? departmentKey});
  void closeChat();
  void setVisitorTyping(String? draftMessage);
  void setPrechatFields(String prechatFields);

  /// Sends a text message. Returns the message ID (clientSideId).
  /// [isHintQuestion] marks the message as a hint/suggestion question (Swift: send(message:, isHintQuestion:)).
  /// [data] optional custom data (Swift: send(message:, data:) DataMessage).
  /// May throw [WebimApiException] or domain errors (e.g. [SendFileError], [SendFilesError], [DataMessageError]).
  Future<String> send(String message, {bool isHintQuestion = false, Map<String, dynamic>? data});

  /// Reply to a message (quote). Returns new message ID or null if cannot reply.
  Future<String?> reply(String message, Message repliedMessage);

  /// Edit a message. Returns true if the message can be edited and request was sent.
  Future<bool> edit(Message message, String text);

  /// Delete a message. Returns true if the message can be deleted and request was sent.
  Future<bool> delete(Message message);

  /// Resend a message that failed (was in sending status). Returns new message ID or null.
  Future<String?> resend(Message message);

  /// Cancel resend / remove message that was not sent.
  void cancelResend(Message message);

  /// Send message with uploaded files (message is JSON array of file descriptions). Returns message ID.
  Future<String> sendUploadedFiles(List<UploadedFile> uploadedFiles);

  /// Send file (upload + send in one request). Returns message ID.
  Future<String> sendFile(List<int> fileBytes, String filename, String mimeType);

  /// Upload file to server only; returns message ID. Use [send] with the returned context for sending.
  Future<String> uploadFilesToServer(List<int> file, String filename, String mimeType);

  /// Delete uploaded file by GUID.
  Future<void> deleteUploadedFiles(String fileGuid);

  /// Send sticker. Returns message ID.
  Future<String> sendSticker(int stickerId);

  /// Rate operator (1..5). If [operatorId] is null, current chat operator is rated. Optional [note] up to 2000 chars.
  Future<void> rateOperator({String? operatorId, required int rating, String? note});

  /// Send resolution survey. [operatorId] required, [answer] 0 or 1.
  Future<void> sendResolutionSurvey({required String operatorId, required int answer});

  /// Respond to sentry call. [id] is the redirect/sentry message id.
  Future<void> respondSentryCall(String id);

  /// Mark chat (or specific message) as read. Pass [messageId] for message-level read.
  Future<void> setChatRead({String? messageId});

  /// Send chat history to email.
  Future<void> sendDialogToEmail(String emailAddress);

  /// Send survey answer. May throw [SendSurveyAnswerError] or [WebimApiException].
  Future<void> sendSurveyAnswer({required String surveyId, required String formId, required String questionId, required String answer});

  /// Close survey. May throw [SurveyCloseError] or [WebimApiException].
  Future<void> closeSurvey(String surveyId);

  /// Send geolocation. May throw [GeolocationError] or [WebimApiException].
  Future<void> sendGeolocation(double latitude, double longitude);

  /// Update widget status (JSON string).
  Future<void> updateWidgetStatus(String data);

  /// Send keyboard response (buttonId, requestMessageId = message's currentChatID).
  Future<void> sendKeyboardRequest({required String buttonId, required String requestMessageId});

  /// React to message (like / dislike). Returns true if sent.
  Future<bool> react(Message message, String reaction);

  /// Search messages by query. Returns list of messages.
  Future<List<Message>> searchStreamMessagesBy(String query);

  /// Clear chat history.
  Future<void> clearHistory();

  /// Get raw config for location.
  Future<Map<String, dynamic>> getRawConfig(String location);

  /// Get server-side settings.
  Future<Map<String, dynamic>> getServerSideSettings();

  /// Autocomplete hints for text. [url] is the hints API URL (e.g. from config). May throw [AutocompleteError] or [WebimApiException].
  Future<List<String>> autocomplete(String text, String url);

  void setVisitSessionStateListener(VisitSessionStateListener? listener);
  void setChatStateListener(ChatStateListener? listener);
  void setCurrentOperatorChangeListener(CurrentOperatorChangeListener? listener);
  void setDepartmentListChangeListener(DepartmentListChangeListener? listener);
  void setLocationSettingsChangeListener(LocationSettingsChangeListener? listener);
  void setOperatorTypingListener(OperatorTypingListener? listener);
  void setOnlineStatusChangeListener(OnlineStatusChangeListener? listener);
  void setUnreadByOperatorTimestampChangeListener(UnreadByOperatorTimestampChangeListener? listener);
  void setUnreadByVisitorMessageCountChangeListener(UnreadByVisitorMessageCountChangeListener? listener);
  void setUnreadByVisitorTimestampChangeListener(UnreadByVisitorTimestampChangeListener? listener);
  void setHelloMessageListener(HelloMessageListener? listener);
  void setSessionLanguageListener(SessionLanguageListener? listener);
  void setSurveyListener(SurveyListener? listener);

  /// Creates a new MessageTracker. Only one active tracker per stream; creating a new one destroys the previous.
  MessageTracker newMessageTracker(MessageListener messageListener);
}
