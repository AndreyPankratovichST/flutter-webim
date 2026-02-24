import 'dart:async';
import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/data/repositories/action_repository_impl.dart';
import 'package:webim/src/data/repositories/message_repository_impl.dart';
import 'package:webim/src/data/repositories/session_repository_impl.dart';
import 'package:webim/src/domain/entities/access_error.dart';
import 'package:webim/src/domain/entities/chat_state.dart';
import 'package:webim/src/domain/entities/client_side_id.dart';
import 'package:webim/src/domain/entities/department.dart';
import 'package:webim/src/domain/entities/location_settings.dart';
import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/entities/message_listener.dart';
import 'package:webim/src/domain/entities/message_stream.dart';
import 'package:webim/src/domain/entities/message_tracker.dart';
import 'package:webim/src/domain/entities/chat_state_listener.dart';
import 'package:webim/src/domain/entities/current_operator_change_listener.dart';
import 'package:webim/src/domain/entities/department_list_change_listener.dart';
import 'package:webim/src/domain/entities/location_settings_change_listener.dart';
import 'package:webim/src/domain/entities/operator.dart';
import 'package:webim/src/domain/entities/hello_message_listener.dart';
import 'package:webim/src/domain/entities/operator_typing_listener.dart';
import 'package:webim/src/domain/entities/online_status_change_listener.dart';
import 'package:webim/src/domain/entities/session.dart';
import 'package:webim/src/domain/entities/survey_listener.dart';
import 'package:webim/src/domain/entities/session_language_listener.dart';
import 'package:webim/src/domain/entities/unread_by_operator_timestamp_change_listener.dart';
import 'package:webim/src/domain/entities/unread_by_visitor_message_count_change_listener.dart';
import 'package:webim/src/domain/entities/unread_by_visitor_timestamp_change_listener.dart';
import 'package:webim/src/domain/entities/uploaded_file.dart';
import 'package:webim/src/domain/entities/visit_session_state.dart';
import 'package:webim/src/data/storage/drift_session_storage.dart';
import 'package:webim/src/data/storage/webim_session_database.dart';
import 'package:webim/src/domain/entities/stored_session_data.dart';
import 'package:webim/src/domain/entities/visit_session_state_listener.dart';
import 'package:webim/src/domain/entities/webim_internal_error.dart';
import 'package:webim/src/domain/entities/webim_session.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';
import 'package:webim/src/presentation/message_tracker_impl.dart';

/// Implementation of WebimSession. Created paused.
class WebimSessionImpl implements WebimSession {
  WebimSessionImpl._({
    required Session session,
    required String location,
    required String deviceId,
    required ApiClient apiClient,
    required SessionRepositoryImpl sessionRepo,
    required MessageRepositoryImpl messageRepo,
    required ActionRepositoryImpl actionRepo,
    required this.baseUrl,
    required this.wsBaseUrl,
    SessionStorage? storage,
    String? storageKey,
    String? pageTitle,
    String? appVersion,
    String? deviceToken,
    String? prechat,
    String? visitorFieldsJsonString,
    String? providedAuthorizationToken,
    bool isPaused = true,
  })  : _session = session,
        _storage = storage,
        _storageKey = storageKey,
        _currentLocation = location,
        _deviceId = deviceId,
        _pageTitle = pageTitle,
        _appVersion = appVersion,
        _deviceToken = deviceToken,
        _prechat = prechat,
        _visitorFieldsJsonString = visitorFieldsJsonString,
        _providedAuthorizationToken = providedAuthorizationToken,
        _apiClient = apiClient,
        _sessionRepo = sessionRepo,
        _messageRepo = messageRepo,
        _actionRepo = actionRepo,
        _isPaused = isPaused {
    _messageStream = MessageStreamImpl(_actionRepo, messageRepo, session.sessionId);
  }

  Session get session => _session;
  Session _session;
  final String baseUrl;
  final String wsBaseUrl;
  /// Current location (for reinit on reinitializationRequired).
  String _currentLocation;
  final String _deviceId;
  final String? _pageTitle;
  final String? _appVersion;
  String? _deviceToken;
  final String? _prechat;
  final String? _visitorFieldsJsonString;
  final String? _providedAuthorizationToken;
  final ApiClient _apiClient;
  final SessionRepositoryImpl _sessionRepo;
  final MessageRepositoryImpl _messageRepo;
  final ActionRepositoryImpl _actionRepo;
  final SessionStorage? _storage;
  final String? _storageKey;
  late final MessageStreamImpl _messageStream;
  bool _isPaused;
  bool _isDestroyed = false;

  static Future<WebimSessionImpl> build({
    required String accountName,
    required String location,
    String? appVersion,
    String? pageTitle,
    String? deviceToken,
    Map<String, String>? requestHeader,
    String? prechat,
    String mobileChatInstance = 'default',
    String? visitorFieldsJsonString,
    String? providedAuthorizationToken,
    bool isLocalHistoryStoragingEnabled = true,
    bool isVisitorDataClearingEnabled = false,
    required String baseUrl,
    required String wsBaseUrl,
    void Function(Object error)? fatalErrorHandler,
    void Function(Object error)? notFatalErrorHandler,
    void Function(String message)? webimLogger,
    Object? remoteNotificationSystem,
    String? multivisitorSection,
    int? onlineStatusRequestFrequencyInMillis,
    Object? webimAlert,
    String? storagePath,
    SessionStorage? sessionStorage,
  }) async {
    final apiClient = ApiClient(baseUrl: baseUrl);
    if (requestHeader != null) apiClient.setRequestHeaders(requestHeader);
    final sessionRepo = SessionRepositoryImpl(apiClient);
    final deviceId = generateClientSideID();

    SessionStorage? storage;
    String? storageKey;
    if (sessionStorage != null) {
      storage = sessionStorage;
      storageKey = '${accountName}_${location}_$mobileChatInstance';
    } else if (storagePath != null && storagePath.isNotEmpty) {
      final db = WebimSessionDatabase.fromPath(storagePath);
      storage = DriftSessionStorage(db);
      storageKey = '${accountName}_${location}_$mobileChatInstance';

      if (isVisitorDataClearingEnabled) {
        final lastAccount = await storage.getLastAccount();
        if (lastAccount != null && lastAccount != accountName) {
          await storage.clearAll();
        }
      }
    }

    StoredSessionData? loaded;
    if (storage != null && storageKey != null) {
      loaded = await storage.load(storageKey);
    }

    final session = await sessionRepo.create(
      location: location,
      deviceId: deviceId,
      pageTitle: pageTitle,
      appVersion: appVersion,
      deviceToken: deviceToken,
      prechat: prechat,
      visitorFieldsJsonString: visitorFieldsJsonString,
      providedAuthorizationToken: providedAuthorizationToken,
      visitSessionId: loaded?.visitSessionId,
      visitorJsonString: loaded?.visitorJsonString,
    );

    if (storage != null && storageKey != null) {
      await storage.save(
        storageKey,
        StoredSessionData(
          visitSessionId: session.sessionId,
          pageId: session.pageId,
          authToken: session.token,
          visitorJsonString: session.visitorJsonString,
        ),
      );
      await storage.setLastAccount(accountName);
    }

    // Webim API uses page-id and auth-token in query/body, not Bearer header.
    final messageRepo = MessageRepositoryImpl(
      apiClient,
      wsBaseUrl,
      baseUrl,
      session.pageId,
      session.token,
    );
    final actionRepo = ActionRepositoryImpl(
      apiClient,
      baseUrl,
      session.pageId,
      session.token,
    );
    return WebimSessionImpl._(
      session: session,
      location: location,
      deviceId: deviceId,
      apiClient: apiClient,
      sessionRepo: sessionRepo,
      messageRepo: messageRepo,
      actionRepo: actionRepo,
      baseUrl: baseUrl,
      wsBaseUrl: wsBaseUrl,
      storage: storage,
      storageKey: storageKey,
      pageTitle: pageTitle,
      appVersion: appVersion,
      deviceToken: deviceToken,
      prechat: prechat,
      visitorFieldsJsonString: visitorFieldsJsonString,
      providedAuthorizationToken: providedAuthorizationToken,
      isPaused: true,
    );
  }

  /// Swift DeltaRequestLoop.change(location:): reset auth, since=0, requestInitialization().
  @override
  void changeLocation(String location) {
    _checkNotDestroyed();
    unawaited(_applyNewLocation(location));
  }

  Future<void> _applyNewLocation(String location) async {
    try {
      final newSession = await _sessionRepo.create(
        location: location,
        deviceId: _deviceId,
        pageTitle: _pageTitle,
        appVersion: _appVersion,
        deviceToken: _deviceToken,
        prechat: _prechat,
        visitorFieldsJsonString: _visitorFieldsJsonString,
        providedAuthorizationToken: _providedAuthorizationToken,
      );
      _session = newSession;
      _currentLocation = location;
      _messageRepo.setAuth(newSession.pageId, newSession.token);
      _actionRepo.setAuth(newSession.pageId, newSession.token);
      _messageStream.setSessionId(newSession.sessionId);
      if (!_isPaused) _requestDelta();
    } catch (_) {
      // Caller can use notFatalErrorHandler if needed
    }
  }

  /// Swift: handleReinitializationRequiredError — reset auth, re-run init.
  void _reinit() {
    if (_isDestroyed || _isPaused) return;
    unawaited(_applyNewLocation(_currentLocation));
  }

  void _checkNotDestroyed() {
    if (_isDestroyed) throw AccessError.invalidSession;
  }

  bool get isPaused => _isPaused;

  @override
  void resume() {
    _checkNotDestroyed();
    _isPaused = false;
    _requestDelta();
  }

  void _requestDelta() {
    unawaited(
      _messageRepo
          .getDelta(sessionId: session.sessionId, since: '0')
          .then((json) {
        if (_isDestroyed || _isPaused) return;
        final error = json['error'];
        if (error is String) {
          if (error == WebimInternalError.reinitializationRequired) {
            _reinit();
          }
          return;
        }
        if (_isDestroyed || _isPaused) return;
        final fullUpdate = json['fullUpdate'];
        if (fullUpdate is Map<String, dynamic>) {
          _messageStream.applyFullUpdate(fullUpdate);
        }
        final deltaList = json['deltaList'];
        if (deltaList is List && !_isDestroyed && !_isPaused) {
          for (final item in deltaList) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            final objectType = map['objectType'] as String?;
            final event = map['event'] as String?;
            if (objectType == 'CHAT_MESSAGE' && event == 'add') {
              final data = map['data'];
              if (data is Map) {
                try {
                  final message = Message.fromJson(Map<String, dynamic>.from(data));
                  _messageStream.pushMessageFromDelta(message);
                } catch (_) {}
              }
            }
          }
        }
      }).catchError((_) {}),
    );
  }

  @override
  void pause() {
    _checkNotDestroyed();
    _isPaused = true;
    // In-flight getDelta() will no-op in .then due to _isPaused check.
  }

  @override
  void destroy() {
    if (_isDestroyed) return;
    _isDestroyed = true;
    _isPaused = true;
    unawaited(_sessionRepo.destroy(sessionId: session.sessionId));
    final storage = _storage;
    final key = _storageKey;
    if (storage != null && key != null) {
      unawaited(storage.clear(key));
    }
    // In-flight requests no-op due to _isDestroyed; no WebSocket held here.
  }

  @override
  void destroyWithClearVisitorData() {
    destroy();
    // Visitor data cleared via storage.clear(key) in destroy().
  }

  @override
  MessageStream getStream() {
    _checkNotDestroyed();
    return _messageStream;
  }

  @override
  @override
  void setDeviceToken(String deviceToken) {
    _checkNotDestroyed();
    // Swift: DeltaRequestLoop.set(deviceToken:); used on next init (e.g. changeLocation).
    _deviceToken = deviceToken;
  }

  @override
  void setRequestHeader(String key, String value) {
    _checkNotDestroyed();
    _apiClient.setRequestHeader(key, value);
  }

  /// For internal use: message repository (e.g. send, history, listen).
  MessageRepositoryImpl get messageRepository => _messageRepo;
}

/// Implementation of MessageStream with mutable state (updated from delta/stream).
class MessageStreamImpl implements MessageStream {
  MessageStreamImpl(this._actionRepo, this._messageRepo, String sessionId)
      : _sessionId = sessionId;

  final ActionRepositoryImpl _actionRepo;
  final MessageRepositoryImpl _messageRepo;
  String _sessionId;

  /// Updates session id after changeLocation (new init returns new visitSessionId).
  void setSessionId(String sessionId) {
    _sessionId = sessionId;
  }

  VisitSessionState _visitSessionState = VisitSessionState.unknown;
  ChatState _chatState = ChatState.closed;
  int? _chatId;
  DateTime? _unreadByOperatorTimestamp;
  DateTime? _unreadByVisitorTimestamp;
  int _unreadByVisitorMessageCount = 0;
  List<Department>? _departmentList;
  LocationSettings _locationSettings = const LocationSettingsImpl();
  Operator? _currentOperator;
  String? _chatLanguage;
  final Map<String, int> _lastRatingOfOperator = {};
  final Map<String, int> _lastResolutionSurveyOfOperator = {};

  MessageTrackerImpl? _currentTracker;

  VisitSessionStateListener? _visitSessionStateListener;
  ChatStateListener? _chatStateListener;
  CurrentOperatorChangeListener? _currentOperatorChangeListener;
  DepartmentListChangeListener? _departmentListChangeListener;
  LocationSettingsChangeListener? _locationSettingsChangeListener;
  // ignore: unused_field - invoked when operator typing events arrive from delta/stream
  OperatorTypingListener? _operatorTypingListener;
  // ignore: unused_field - invoked when online status events arrive from delta/stream
  OnlineStatusChangeListener? _onlineStatusChangeListener;
  UnreadByOperatorTimestampChangeListener? _unreadByOperatorTimestampChangeListener;
  UnreadByVisitorMessageCountChangeListener? _unreadByVisitorMessageCountChangeListener;
  UnreadByVisitorTimestampChangeListener? _unreadByVisitorTimestampChangeListener;
  // ignore: unused_field - invoked when hello message arrives from delta/stream
  HelloMessageListener? _helloMessageListener;
  SessionLanguageListener? _sessionLanguageListener;
  // ignore: unused_field - invoked when survey events arrive from delta/stream
  SurveyListener? _surveyListener;

  /// Applies fullUpdate from delta response (FullUpdate.swift: state, chat, departments, hintsEnabled).
  void applyFullUpdate(Map<String, dynamic>? fullUpdate) {
    if (fullUpdate == null) return;
    final oldVisit = _visitSessionState;
    final oldLocation = _locationSettings;

    final state = fullUpdate['state'] as String?;
    if (state != null) _visitSessionState = _parseVisitSessionState(state);
    final hintsEnabled = fullUpdate['hintsEnabled'] as bool? ?? false;
    _locationSettings = LocationSettingsImpl(areHintsEnabled: hintsEnabled);
    final departmentsData = fullUpdate['departments'] as List<dynamic>?;
    if (departmentsData != null) {
      _departmentList = departmentsData
          .map((e) => Department.fromJson(e is Map ? Map<String, dynamic>.from(e) : null))
          .whereType<Department>()
          .toList();
    }
    final chat = fullUpdate['chat'] as Map<String, dynamic>?;
    if (chat != null) _applyChat(chat);

    if (oldVisit != _visitSessionState) _visitSessionStateListener?.changed(oldVisit, _visitSessionState);
    if (oldLocation.areHintsEnabled != _locationSettings.areHintsEnabled) {
      _locationSettingsChangeListener?.changed(oldLocation, _locationSettings);
    }
    if (departmentsData != null && _departmentList != null) {
      _departmentListChangeListener?.received(_departmentList!);
    }
  }

  static VisitSessionState _parseVisitSessionState(String s) {
    switch (s) {
      case 'chat':
        return VisitSessionState.chat;
      case 'department-selection':
        return VisitSessionState.departmentSelection;
      case 'idle':
        return VisitSessionState.idle;
      case 'idle-after-chat':
        return VisitSessionState.idleAfterChat;
      case 'offline-message':
        return VisitSessionState.offlineMessage;
      case 'first-question':
        return VisitSessionState.firstQuestion;
      default:
        return VisitSessionState.unknown;
    }
  }

  static ChatState _parseChatState(String? s) {
    if (s == null) return ChatState.unknown;
    switch (s) {
      case 'chatting':
        return ChatState.chatting;
      case 'chatting_with_robot':
        return ChatState.chattingWithRobot;
      case 'closed':
        return ChatState.closed;
      case 'closed_by_operator':
        return ChatState.closedByOperator;
      case 'closed_by_visitor':
        return ChatState.closedByVisitor;
      case 'invitation':
        return ChatState.invitation;
      case 'queue':
        return ChatState.queue;
      default:
        return ChatState.unknown;
    }
  }

  void _applyChat(Map<String, dynamic> chat) {
    final oldChatState = _chatState;
    final oldOperator = _currentOperator;
    final oldUnreadOp = _unreadByOperatorTimestamp;
    final oldUnreadCnt = _unreadByVisitorMessageCount;
    final oldUnreadVis = _unreadByVisitorTimestamp;
    final oldLang = _chatLanguage;

    final id = chat['id'];
    if (id is int) _chatId = id;
    _chatState = _parseChatState(chat['state'] as String?);
    final op = chat['operator'] as Map<String, dynamic>?;
    _currentOperator = op != null ? OperatorImpl.fromJson(op) : null;
    final ts = chat['unreadByOperatorSinceTs'];
    if (ts is num) _unreadByOperatorTimestamp = DateTime.fromMillisecondsSinceEpoch((ts * 1000).round());
    final cnt = chat['unreadByVisitorMsgCnt'];
    if (cnt is int) _unreadByVisitorMessageCount = cnt;
    final tsV = chat['unreadByVisitorSinceTs'];
    if (tsV is num) _unreadByVisitorTimestamp = DateTime.fromMillisecondsSinceEpoch((tsV * 1000).round());
    final lang = chat['language'] as String?;
    if (lang != null) _chatLanguage = lang;

    if (oldChatState != _chatState) _chatStateListener?.changed(oldChatState, _chatState);
    if (oldOperator?.id != _currentOperator?.id || oldOperator?.name != _currentOperator?.name) {
      _currentOperatorChangeListener?.changed(oldOperator, _currentOperator);
    }
    if (oldUnreadOp != _unreadByOperatorTimestamp) {
      _unreadByOperatorTimestampChangeListener?.changedUnreadByOperatorTimestampTo(_unreadByOperatorTimestamp);
    }
    if (oldUnreadCnt != _unreadByVisitorMessageCount) {
      _unreadByVisitorMessageCountChangeListener?.changedUnreadByVisitorMessageCountTo(_unreadByVisitorMessageCount);
    }
    if (oldUnreadVis != _unreadByVisitorTimestamp) {
      _unreadByVisitorTimestampChangeListener?.changedUnreadByVisitorTimestampTo(_unreadByVisitorTimestamp);
    }
    if (oldLang != _chatLanguage) _sessionLanguageListener?.changed(_chatLanguage);
  }

  @override
  VisitSessionState getVisitSessionState() => _visitSessionState;

  @override
  ChatState getChatState() => _chatState;

  @override
  int? getChatId() => _chatId;

  @override
  DateTime? getUnreadByOperatorTimestamp() => _unreadByOperatorTimestamp;

  @override
  DateTime? getUnreadByVisitorTimestamp() => _unreadByVisitorTimestamp;

  @override
  int getUnreadByVisitorMessageCount() => _unreadByVisitorMessageCount;

  @override
  List<Department>? getDepartmentList() => _departmentList;

  @override
  LocationSettings getLocationSettings() => _locationSettings;

  @override
  Operator? getCurrentOperator() => _currentOperator;

  @override
  String? getChatLanguage() => _chatLanguage;

  @override
  int getLastRatingOfOperatorWith(String id) =>
      _lastRatingOfOperator[id] ?? 0;

  @override
  int? getLastResolutionSurveyWith(String operatorId) =>
      _lastResolutionSurveyOfOperator[operatorId];

  @override
  void startChat({
    String? firstQuestion,
    String? departmentKey,
    String? customFields,
    bool forceStart = false,
  }) {
    unawaited(_actionRepo.startChat(
      clientSideId: generateClientSideID(),
      firstQuestion: firstQuestion,
      departmentKey: departmentKey,
      customFields: customFields,
      forceStart: forceStart,
    ));
  }

  @override
  void forceStartChat({String? departmentKey}) {
    startChat(departmentKey: departmentKey, forceStart: true);
  }

  @override
  void closeChat() {
    unawaited(_actionRepo.closeChat());
  }

  @override
  void setVisitorTyping(String? draftMessage) {
    unawaited(_actionRepo.setVisitorTyping(
      typing: draftMessage != null && draftMessage.isNotEmpty,
      draft: draftMessage,
      deleteDraft: draftMessage == null || draftMessage.isEmpty,
    ));
  }

  @override
  void setPrechatFields(String prechatFields) {
    unawaited(_actionRepo.setPrechatFields(prechatFields));
  }

  @override
  Future<String> send(String message, {bool isHintQuestion = false, Map<String, dynamic>? data}) {
    final id = generateClientSideID();
    return _actionRepo
        .sendMessage(
          clientSideId: id,
          message: message,
          isHintQuestion: isHintQuestion,
          data: data,
        )
        .then((_) => id);
  }

  @override
  Future<String?> reply(String message, Message repliedMessage) async {
    if (!repliedMessage.canBeReplied) return null;
    final id = generateClientSideID();
    final quotedId = repliedMessage.serverSideID ?? repliedMessage.id;
    try {
      await _actionRepo.replyMessage(
        clientSideId: id,
        message: message,
        quotedMessageId: quotedId,
      );
      return id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> edit(Message message, String text) {
    if (!message.canBeEdited) return Future.value(false);
    return _actionRepo
        .sendMessage(clientSideId: message.id, message: text)
        .then((_) => true)
        .catchError((_) => false);
  }

  @override
  Future<bool> delete(Message message) {
    return _actionRepo
        .deleteMessage(message.id)
        .then((_) => true)
        .catchError((_) => false);
  }

  @override
  Future<String?> resend(Message message) async {
    try {
      await _actionRepo.sendMessage(
        clientSideId: message.id,
        message: message.text,
      );
      return message.id;
    } catch (_) {
      return null;
    }
  }

  @override
  void cancelResend(Message message) {
    // Local only: client may remove the message from UI. No server action in Swift for cancel.
  }

  @override
  Future<String> sendUploadedFiles(List<UploadedFile> uploadedFiles) async {
    if (uploadedFiles.isEmpty) return generateClientSideID();
    if (uploadedFiles.length > 10) return generateClientSideID();
    final id = generateClientSideID();
    final message = '[${uploadedFiles.map((f) => f.description).join(', ')}]';
    await _actionRepo.sendFiles(message, id);
    return id;
  }

  @override
  Future<String> sendFile(List<int> fileBytes, String filename, String mimeType) async {
    final id = generateClientSideID();
    await _actionRepo.uploadFile(fileBytes, filename, mimeType, id);
    return id;
  }

  @override
  Future<String> uploadFilesToServer(List<int> fileBytes, String filename, String mimeType) async {
    final id = generateClientSideID();
    await _actionRepo.uploadFile(fileBytes, filename, mimeType, id);
    return id;
  }

  @override
  Future<void> deleteUploadedFiles(String fileGuid) async {
    await _actionRepo.deleteUploadedFile(fileGuid);
  }

  @override
  Future<String> sendSticker(int stickerId) async {
    final id = generateClientSideID();
    await _actionRepo.sendSticker(stickerId, id);
    return id;
  }

  @override
  Future<void> rateOperator({String? operatorId, required int rating, String? note}) async {
    if (rating < 1 || rating > 5) return;
    await _actionRepo.rateOperator(
      operatorId: operatorId,
      rating: rating,
      note: note,
      threadId: _chatId,
    );
  }

  @override
  Future<void> sendResolutionSurvey({required String operatorId, required int answer}) async {
    if (answer != 0 && answer != 1) return;
    await _actionRepo.sendResolutionSurvey(
      operatorId: operatorId,
      answer: answer,
      threadId: _chatId,
    );
  }

  @override
  Future<void> respondSentryCall(String id) async {
    await _actionRepo.respondSentryCall(id);
  }

  @override
  Future<void> setChatRead({String? messageId}) async {
    await _actionRepo.setChatRead(messageId: messageId);
  }

  @override
  Future<void> sendDialogToEmail(String emailAddress) async {
    await _actionRepo.sendDialogToEmail(emailAddress);
  }

  @override
  Future<void> sendSurveyAnswer({
    required String surveyId,
    required String formId,
    required String questionId,
    required String answer,
  }) async {
    await _actionRepo.sendSurveyAnswer(
      surveyId: surveyId,
      formId: formId,
      questionId: questionId,
      answer: answer,
    );
  }

  @override
  Future<void> closeSurvey(String surveyId) async {
    await _actionRepo.closeSurvey(surveyId);
  }

  @override
  Future<void> sendGeolocation(double latitude, double longitude) async {
    await _actionRepo.sendGeolocation(latitude, longitude);
  }

  @override
  Future<void> updateWidgetStatus(String data) async {
    await _actionRepo.updateWidgetStatus(data);
  }

  @override
  Future<void> sendKeyboardRequest({
    required String buttonId,
    required String requestMessageId,
  }) async {
    await _actionRepo.sendKeyboardRequest(
      buttonId: buttonId,
      requestMessageId: requestMessageId,
    );
  }

  @override
  Future<bool> react(Message message, String reaction) async {
    if (reaction != 'like' && reaction != 'dislike') return false;
    try {
      await _actionRepo.sendReaction(message.id, reaction);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<Message>> searchStreamMessagesBy(String query) async {
    final result = await _actionRepo.searchMessages(query);
    final data = result['data'];
    if (data is! Map<String, dynamic>) return [];
    final items = data['items'] as List<dynamic>?;
    if (items == null) return [];
    return items
        .map((e) => e is Map ? Message.fromJson(Map<String, dynamic>.from(e)) : null)
        .whereType<Message>()
        .toList();
  }

  @override
  Future<void> clearHistory() async {
    await _actionRepo.clearHistory();
  }

  @override
  Future<Map<String, dynamic>> getRawConfig(String location) async {
    return _actionRepo.getRawConfig(location);
  }

  @override
  Future<Map<String, dynamic>> getServerSideSettings() async {
    return _actionRepo.getServerSideSettings();
  }

  @override
  Future<List<String>> autocomplete(String text, String url) async {
    return _actionRepo.autocomplete(text, url);
  }

  @override
  void setVisitSessionStateListener(VisitSessionStateListener? listener) {
    _visitSessionStateListener = listener;
  }

  @override
  void setChatStateListener(ChatStateListener? listener) {
    _chatStateListener = listener;
  }

  @override
  void setCurrentOperatorChangeListener(CurrentOperatorChangeListener? listener) {
    _currentOperatorChangeListener = listener;
  }

  @override
  void setDepartmentListChangeListener(DepartmentListChangeListener? listener) {
    _departmentListChangeListener = listener;
  }

  @override
  void setLocationSettingsChangeListener(LocationSettingsChangeListener? listener) {
    _locationSettingsChangeListener = listener;
  }

  @override
  void setOperatorTypingListener(OperatorTypingListener? listener) {
    _operatorTypingListener = listener;
  }

  @override
  void setOnlineStatusChangeListener(OnlineStatusChangeListener? listener) {
    _onlineStatusChangeListener = listener;
  }

  @override
  void setUnreadByOperatorTimestampChangeListener(UnreadByOperatorTimestampChangeListener? listener) {
    _unreadByOperatorTimestampChangeListener = listener;
  }

  @override
  void setUnreadByVisitorMessageCountChangeListener(UnreadByVisitorMessageCountChangeListener? listener) {
    _unreadByVisitorMessageCountChangeListener = listener;
  }

  @override
  void setUnreadByVisitorTimestampChangeListener(UnreadByVisitorTimestampChangeListener? listener) {
    _unreadByVisitorTimestampChangeListener = listener;
  }

  @override
  void setHelloMessageListener(HelloMessageListener? listener) {
    _helloMessageListener = listener;
  }

  @override
  void setSessionLanguageListener(SessionLanguageListener? listener) {
    _sessionLanguageListener = listener;
  }

  @override
  void setSurveyListener(SurveyListener? listener) {
    _surveyListener = listener;
  }

  @override
  MessageTracker newMessageTracker(MessageListener messageListener) {
    _currentTracker?.destroy();
    _currentTracker = MessageTrackerImpl(_messageRepo, _sessionId, messageListener);
    return _currentTracker!;
  }

  /// Pushes a message from delta (CHAT_MESSAGE add) to the current tracker's listener.
  void pushMessageFromDelta(Message message) {
    _currentTracker?.pushMessageFromDelta(message);
  }
}
