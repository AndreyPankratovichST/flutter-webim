import 'dart:convert';

import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/data/error_parser.dart';
import 'package:webim/src/domain/entities/uploaded_file_impl.dart';
import 'package:webim/src/domain/entities/webim_api_exception.dart';
import 'package:webim/src/domain/repositories/action_repository.dart';

/// Swift WebimActionsImpl: action=chat.start, chat.close, chat.visitor_typing; form-urlencoded to /l/v/m/action.
/// Webim API requires page-id and auth-token in every action body.
class ActionRepositoryImpl implements ActionRepository {
  final ApiClient _client;
  final String _actionBaseUrl;
  String? _pageId;
  String? _authToken;

  ActionRepositoryImpl(this._client, this._actionBaseUrl, [String? pageId, String? authToken])
      : _pageId = pageId,
        _authToken = authToken;

  /// Updates auth after changeLocation (Swift: authorizationData reset then requestInitialization).
  void setAuth(String? pageId, String? authToken) {
    _pageId = pageId;
    _authToken = authToken;
  }

  Map<String, String> _bodyWithAuth(Map<String, String> body) {
    final pid = _pageId;
    final tok = _authToken;
    if (pid != null && pid.isNotEmpty && tok != null && tok.isNotEmpty) {
      return {...body, 'page-id': pid, 'auth-token': tok};
    }
    return body;
  }

  Never _rethrowTyped(Object e, ActionErrorContext context) {
    if (e is WebimApiException) {
      final typed = parseActionError(e, context);
      if (typed != null) throw typed;
    }
    throw e;
  }

  String get _actionUrl => '$_actionBaseUrl/l/v/m/action';
  String get _uploadUrl => '$_actionBaseUrl/l/v/m/upload';
  String get _fileDeleteUrl => '$_actionBaseUrl/l/v/file-delete';
  String get _searchUrl => '$_actionBaseUrl/l/v/m/search-messages';
  String _configUrl(String location) => '$_actionBaseUrl/api/visitor/v1/configs/$location';
  String get _serverSideSettingsUrl => '$_actionBaseUrl/x/js/v/all-settings-mobile.js';

  @override
  Future<void> startChat({
    required String clientSideId,
    String? firstQuestion,
    String? departmentKey,
    String? customFields,
    bool forceStart = false,
  }) async {
    final body = <String, String>{
      'action': 'chat.start',
      'force-online': 'true',
      'client-side-id': clientSideId,
    };
    if (firstQuestion != null) body['first-question'] = firstQuestion;
    if (departmentKey != null) body['department-key'] = departmentKey;
    if (customFields != null) body['custom_fields'] = customFields;
    if (forceStart) body['force-start'] = 'true';
    await _client.postForm(_actionUrl, _bodyWithAuth(body));
  }

  @override
  Future<void> closeChat() async {
    await _client.postForm(_actionUrl, _bodyWithAuth({'action': 'chat.close'}));
  }

  @override
  Future<void> setVisitorTyping({
    required bool typing,
    String? draft,
    bool deleteDraft = false,
  }) async {
    final body = <String, String>{
      'action': 'chat.visitor_typing',
      'del-message-draft': deleteDraft ? '1' : '0',
      'typing': typing ? '1' : '0',
    };
    if (draft != null) body['message-draft'] = draft;
    await _client.postForm(_actionUrl, _bodyWithAuth(body));
  }

  @override
  Future<void> setPrechatFields(String prechatFields) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.set_prechat_fields',
      'prechat-key-independent-fields': prechatFields,
    }));
  }

  @override
  Future<void> sendMessage({
    required String clientSideId,
    required String message,
    bool isHintQuestion = false,
    Map<String, dynamic>? data,
  }) async {
    final body = <String, String>{
      'action': 'chat.message',
      'client-side-id': clientSideId,
      'message': message,
    };
    if (isHintQuestion) body['hint_question'] = 'true';
    if (data != null && data.isNotEmpty) {
      body['data'] = jsonEncode(data);
    }
    try {
      await _client.postForm(_actionUrl, _bodyWithAuth(body));
    } catch (e) {
      _rethrowTyped(e, ActionErrorContext.dataMessage);
    }
  }

  @override
  Future<void> replyMessage({
    required String clientSideId,
    required String message,
    required String quotedMessageId,
  }) async {
    final quote = '{"ref":{"msgId":"$quotedMessageId","msgChannelSideId":null,"chatId":null}}';
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.message',
      'client-side-id': clientSideId,
      'message': message,
      'quote': quote,
    }));
  }

  @override
  Future<void> deleteMessage(String clientSideId) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.delete_message',
      'client-side-id': clientSideId,
    }));
  }

  @override
  Future<UploadedFileImpl> uploadFile(
    List<int> fileBytes,
    String filename,
    String mimeType,
    String clientSideId,
  ) async {
    final body = await _client.postMultipart(
      _uploadUrl,
      _bodyWithAuth({
        'chat-mode': 'online',
        'client-side-id': clientSideId,
      }),
      fileBytes,
      'file',
      filename,
      mimeType,
    );
    return UploadedFileImpl.fromJson(Map<String, dynamic>.from(body));
  }

  @override
  Future<void> sendFiles(String message, String clientSideId) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.message',
      'client-side-id': clientSideId,
      'message': message,
      'kind': 'file_visitor',
    }));
  }

  @override
  Future<void> deleteUploadedFile(String fileGuid) async {
    final params = <String, String>{'guid': fileGuid, ..._bodyWithAuth({})};
    await _client.getFullUrl(_fileDeleteUrl, queryParameters: params);
  }

  @override
  Future<void> sendSticker(int stickerId, String clientSideId) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'sticker',
      'client-side-id': clientSideId,
      'sticker-id': stickerId.toString(),
    }));
  }

  @override
  Future<void> rateOperator({
    String? operatorId,
    required int rating,
    String? note,
    int? threadId,
  }) async {
    final body = <String, String>{
      'action': 'chat.operator_rate_select',
      'rate': (rating - 3).toString(),
    };
    if (operatorId != null) body['operator_id'] = operatorId;
    if (note != null) body['visitor_note'] = note;
    if (threadId != null) body['thread_id'] = threadId.toString();
    await _client.postForm(_actionUrl, _bodyWithAuth(body));
  }

  @override
  Future<void> sendResolutionSurvey({
    required String operatorId,
    required int answer,
    int? threadId,
  }) async {
    final body = <String, String>{
      'action': 'chat.resolution_survey_select',
      'answer': answer.toString(),
      'operator_id': operatorId,
    };
    if (threadId != null) body['thread_id'] = threadId.toString();
    await _client.postForm(_actionUrl, _bodyWithAuth(body));
  }

  @override
  Future<void> respondSentryCall(String id) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.action_request.call_sentry_action_request',
      'client-side-id': id,
    }));
  }

  @override
  Future<void> setChatRead({String? messageId}) async {
    final body = <String, String>{'action': 'chat.read_by_visitor'};
    if (messageId != null) body['message_id'] = messageId;
    await _client.postForm(_actionUrl, _bodyWithAuth(body));
  }

  @override
  Future<void> sendDialogToEmail(String emailAddress) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.send_chat_history',
      'email': emailAddress,
    }));
  }

  @override
  Future<void> sendSurveyAnswer({
    required String surveyId,
    required String formId,
    required String questionId,
    required String answer,
  }) async {
    try {
      await _client.postForm(_actionUrl, _bodyWithAuth({
        'action': 'survey.answer',
        'survey-id': surveyId,
        'form-id': formId,
        'question-id': questionId,
        'answer': answer,
      }));
    } catch (e) {
      _rethrowTyped(e, ActionErrorContext.surveyAnswer);
    }
  }

  @override
  Future<void> closeSurvey(String surveyId) async {
    try {
      await _client.postForm(_actionUrl, _bodyWithAuth({
        'action': 'survey.cancel',
        'survey-id': surveyId,
      }));
    } catch (e) {
      _rethrowTyped(e, ActionErrorContext.surveyClose);
    }
  }

  @override
  Future<void> sendGeolocation(double latitude, double longitude) async {
    try {
      await _client.postForm(_actionUrl, _bodyWithAuth({
        'action': 'geo_response',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      }));
    } catch (e) {
      _rethrowTyped(e, ActionErrorContext.geolocation);
    }
  }

  @override
  Future<void> updateWidgetStatus(String data) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'widget.update',
      'data': data,
    }));
  }

  @override
  Future<void> sendKeyboardRequest({
    required String buttonId,
    required String requestMessageId,
  }) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.keyboard_response',
      'button-id': buttonId,
      'request-message-id': requestMessageId,
    }));
  }

  @override
  Future<void> sendReaction(String clientSideId, String reaction) async {
    await _client.postForm(_actionUrl, _bodyWithAuth({
      'action': 'chat.react_message',
      'client-side-id': clientSideId,
      'reaction': reaction,
    }));
  }

  @override
  Future<Map<String, dynamic>> searchMessages(String query) async {
    final params = <String, String>{'query': query, ..._bodyWithAuth({})};
    final result = await _client.getFullUrl(_searchUrl, queryParameters: params);
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> clearHistory() async {
    await _client.postForm(_actionUrl, _bodyWithAuth({'action': 'chat.clear_history'}));
  }

  @override
  Future<Map<String, dynamic>> getRawConfig(String location) async {
    final result = await _client.getFullUrl(_configUrl(location));
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<Map<String, dynamic>> getServerSideSettings() async {
    try {
      final result = await _client.getFullUrl(_serverSideSettingsUrl);
      return Map<String, dynamic>.from(result);
    } catch (_) {
      return {};
    }
  }

  @override
  Future<List<String>> autocomplete(String text, String url) async {
    try {
      final result = await _client.postToUrlNoAuth(url, {'text': text});
      final list = result['hints'] as List<dynamic>? ?? result['items'] as List<dynamic>? ?? result as List<dynamic>?;
      if (list == null) return [];
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      _rethrowTyped(e, ActionErrorContext.autocomplete);
    }
  }
}
