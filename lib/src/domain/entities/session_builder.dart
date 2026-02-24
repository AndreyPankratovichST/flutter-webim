import 'package:webim/src/domain/entities/client_side_id.dart';
import 'package:webim/src/domain/entities/session_builder_error.dart';
import 'package:webim/src/domain/entities/webim_session.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';
import 'package:webim/src/presentation/webim_session_impl.dart';

/// Called on fatal error (Swift: FatalErrorHandler).
typedef FatalErrorHandler = void Function(Object error);

/// Called on non-fatal error (Swift: NotFatalErrorHandler).
typedef NotFatalErrorHandler = void Function(Object error);

/// Logger callback (Swift: WebimLogger).
typedef WebimLogger = void Function(String message);

/// SessionBuilder for creating WebimSession.
/// See Webim.swift SessionBuilder.
class SessionBuilder {
  String? _accountName;
  String? _location;
  String? _appVersion;
  String? _pageTitle;
  String? _deviceToken;
  Map<String, String>? _requestHeader;
  String? _prechat;
  String? _mobileChatInstance;
  String? _visitorFieldsJsonString;
  ProvidedAuthorizationTokenStateListener? _providedAuthorizationTokenStateListener;
  String? _providedAuthorizationToken;
  bool _isLocalHistoryStoragingEnabled = true;
  bool _isVisitorDataClearingEnabled = false;
  String? _storagePath;
  SessionStorage? _sessionStorage;
  String? _baseUrl;
  String? _wsBaseUrl;

  FatalErrorHandler? _fatalErrorHandler;
  NotFatalErrorHandler? _notFatalErrorHandler;
  WebimLogger? _webimLogger;
  String? _multivisitorSection;
  int? _onlineStatusRequestFrequencyInMillis;
  Object? _webimAlert;
  Object? _remoteNotificationSystem;

  SessionBuilder setAccountName(String accountName) {
    _accountName = accountName;
    return this;
  }

  SessionBuilder setLocation(String location) {
    _location = location;
    return this;
  }

  SessionBuilder setAppVersion(String? appVersion) {
    _appVersion = appVersion;
    return this;
  }

  SessionBuilder setPageTitle(String? pageTitle) {
    _pageTitle = pageTitle;
    return this;
  }

  SessionBuilder setDeviceToken(String? deviceToken) {
    _deviceToken = deviceToken;
    return this;
  }

  SessionBuilder setRequestHeader(Map<String, String> requestHeader) {
    _requestHeader = requestHeader;
    return this;
  }

  SessionBuilder setPrechat(String? prechat) {
    _prechat = prechat;
    return this;
  }

  SessionBuilder setMobileChatInstance(String? mobileChatInstance) {
    _mobileChatInstance = mobileChatInstance;
    return this;
  }

  /// Visitor fields JSON string (signed on backend). Cannot be used with providedAuthorizationToken.
  SessionBuilder setVisitorFieldsJsonString(String? visitorFieldsJsonString) {
    _visitorFieldsJsonString = visitorFieldsJsonString;
    return this;
  }

  /// Custom auth token. Cannot be used with visitorFields.
  SessionBuilder setProvidedAuthorizationToken(
    ProvidedAuthorizationTokenStateListener? listener, {
    String? providedAuthorizationToken,
  }) {
    _providedAuthorizationTokenStateListener = listener;
    _providedAuthorizationToken = providedAuthorizationToken;
    return this;
  }

  SessionBuilder setLocalHistoryStoragingEnabled(bool enabled) {
    _isLocalHistoryStoragingEnabled = enabled;
    return this;
  }

  SessionBuilder setVisitorDataClearingEnabled(bool enabled) {
    _isVisitorDataClearingEnabled = enabled;
    return this;
  }

  /// Optional: directory path for session DB (e.g. from getApplicationDocumentsDirectory()).
  /// When [isLocalHistoryStoragingEnabled], Drift storage is used; default path is 'webim_sessions.db'.
  /// Ignored if [setSessionStorage] was called.
  SessionBuilder setStoragePath(String? path) {
    _storagePath = path;
    return this;
  }

  /// Optional: use a single [SessionStorage] instance (e.g. one Drift DB per app) to avoid Drift
  /// "multiple databases" warning. When set, [setStoragePath] is ignored for this build.
  SessionBuilder setSessionStorage(SessionStorage? storage) {
    _sessionStorage = storage;
    return this;
  }

  /// Optional: override API base URL.
  /// Default when not set: if [accountName] is full URL then {accountName}/api/v1,
  /// else https://{accountName}.webim.ru/api/v1 (same as FAQBuilder).
  SessionBuilder setBaseUrl(String? baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  /// Optional: override WebSocket base URL.
  /// Default when not set: wss from base URL or wss://{accountName}.webim.ru.
  SessionBuilder setWsBaseUrl(String? wsBaseUrl) {
    _wsBaseUrl = wsBaseUrl;
    return this;
  }

  SessionBuilder setFatalErrorHandler(FatalErrorHandler? handler) {
    _fatalErrorHandler = handler;
    return this;
  }

  SessionBuilder setNotFatalErrorHandler(NotFatalErrorHandler? handler) {
    _notFatalErrorHandler = handler;
    return this;
  }

  SessionBuilder setWebimLogger(WebimLogger? logger) {
    _webimLogger = logger;
    return this;
  }

  SessionBuilder setRemoteNotificationSystem(Object? system) {
    _remoteNotificationSystem = system;
    return this;
  }

  SessionBuilder setMultivisitorSection(String? section) {
    _multivisitorSection = section;
    return this;
  }

  SessionBuilder setOnlineStatusRequestFrequencyInMillis(int? millis) {
    _onlineStatusRequestFrequencyInMillis = millis;
    return this;
  }

  SessionBuilder setWebimAlert(Object? alert) {
    _webimAlert = alert;
    return this;
  }

  /// Webim API uses root URL (no /api/v1): paths are /l/v/m/init, /l/v/m/delta, /l/v/m/action.
  String get _resolvedBaseUrl {
    if (_baseUrl != null && _baseUrl!.isNotEmpty) return _baseUrl!;
    final a = _accountName ?? '';
    if (a.isEmpty) return '';
    if (a.startsWith('https://') || a.startsWith('http://')) {
      return a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    }
    return 'https://$a.webim.ru';
  }

  String get _resolvedWsBaseUrl {
    if (_wsBaseUrl != null && _wsBaseUrl!.isNotEmpty) return _wsBaseUrl!;
    final a = _accountName ?? '';
    if (a.isEmpty) return '';
    if (a.startsWith('https://')) return a.replaceFirst('https://', 'wss://');
    if (a.startsWith('http://')) return a.replaceFirst('http://', 'ws://');
    return 'wss://$a.webim.ru';
  }

  /// Builds new WebimSession. Session is created paused; call resume() to start.
  /// Throws SessionBuilderError if validation fails.
  Future<WebimSession> build() async {
    if (_accountName == null || _accountName!.isEmpty) {
      throw SessionBuilderError.nilAccountName;
    }
    if (_location == null || _location!.isEmpty) {
      throw SessionBuilderError.nilLocation;
    }
    if (_visitorFieldsJsonString != null &&
        _visitorFieldsJsonString!.isNotEmpty &&
        _providedAuthorizationTokenStateListener != null) {
      throw SessionBuilderError.invalidAuthentificatorParameters;
    }
    if (_providedAuthorizationToken == null &&
        _providedAuthorizationTokenStateListener != null) {
      _providedAuthorizationToken = generateClientSideID();
      _providedAuthorizationTokenStateListener!
          .update(_providedAuthorizationToken!);
    }
    final useStorage = _isLocalHistoryStoragingEnabled;
    final SessionStorage? sessionStorage = _sessionStorage;
    final path = (sessionStorage == null && useStorage)
        ? (_storagePath ?? 'webim_sessions.db')
        : null;
    return WebimSessionImpl.build(
      accountName: _accountName!,
      location: _location!,
      appVersion: _appVersion,
      pageTitle: _pageTitle,
      deviceToken: _deviceToken,
      requestHeader: _requestHeader,
      prechat: _prechat,
      mobileChatInstance: _mobileChatInstance ?? 'default',
      visitorFieldsJsonString: _visitorFieldsJsonString,
      providedAuthorizationToken: _providedAuthorizationToken,
      isLocalHistoryStoragingEnabled: _isLocalHistoryStoragingEnabled,
      isVisitorDataClearingEnabled: _isVisitorDataClearingEnabled,
      baseUrl: _resolvedBaseUrl,
      wsBaseUrl: _resolvedWsBaseUrl,
      fatalErrorHandler: _fatalErrorHandler,
      notFatalErrorHandler: _notFatalErrorHandler,
      webimLogger: _webimLogger,
      remoteNotificationSystem: _remoteNotificationSystem,
      multivisitorSection: _multivisitorSection,
      onlineStatusRequestFrequencyInMillis: _onlineStatusRequestFrequencyInMillis,
      webimAlert: _webimAlert,
      storagePath: path,
      sessionStorage: sessionStorage,
    );
  }
}

/// Called when provided authorization token is updated.
abstract class ProvidedAuthorizationTokenStateListener {
  void update(String providedAuthorizationToken);
}
