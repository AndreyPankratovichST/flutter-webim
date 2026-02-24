import 'dart:convert';

import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/domain/entities/session.dart';
import 'package:webim/src/domain/entities/webim_api_exception.dart';
import 'package:webim/src/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  static const String _initPath = '/l/v/m/init';
  static const String _sdkVersionHeader = 'x-webim-sdk-version';

  final ApiClient _client;

  SessionRepositoryImpl(this._client);

  @override
  Future<Session> create({
    required String location,
    required String deviceId,
    String? pageTitle,
    String? appVersion,
    String? deviceToken,
    String? prechat,
    String? visitorFieldsJsonString,
    String? providedAuthorizationToken,
    String? visitSessionId,
    String? visitorJsonString,
  }) async {
    final query = <String, String>{
      'device-id': deviceId,
      'event': 'init',
      'location': location,
      'platform': 'web',
      'respond-immediately': 'true',
      'since': '0',
      'title': pageTitle ?? 'Flutter',
    };
    if (appVersion != null && appVersion.isNotEmpty) {
      query['app-version'] = appVersion;
    }
    if (deviceToken != null && deviceToken.isNotEmpty) {
      query['push-token'] = deviceToken;
    }
    if (prechat != null && prechat.isNotEmpty) {
      query['prechat-key-independent-fields'] = prechat;
    }
    if (visitorFieldsJsonString != null && visitorFieldsJsonString.isNotEmpty) {
      query['visitor-ext'] = visitorFieldsJsonString;
    }
    if (providedAuthorizationToken != null &&
        providedAuthorizationToken.isNotEmpty) {
      query['provided_auth_token'] = providedAuthorizationToken;
    }
    if (visitSessionId != null && visitSessionId.isNotEmpty) {
      query['visit-session-id'] = visitSessionId;
    }
    if (visitorJsonString != null && visitorJsonString.isNotEmpty) {
      query['visitor'] = visitorJsonString;
    }

    final json = await _client.get(
      _initPath,
      query: query,
      headers: {_sdkVersionHeader: '1.0.0'},
    );

    final error = json['error'];
    if (error != null) {
      final message = error is String ? error : 'Initialization failed';
      final internalError = error is String ? error : null;
      throw WebimApiException(message: message, internalError: internalError);
    }

    final fullUpdate = json['fullUpdate'];
    if (fullUpdate is! Map<String, dynamic>) {
      throw WebimApiException(message: 'Missing fullUpdate in init response');
    }

    final sessionId = fullUpdate['visitSessionId'] as String? ?? '';
    final token = fullUpdate['authToken'] as String? ?? '';
    final pageId = fullUpdate['pageId'] as String? ?? '';
    if (sessionId.isEmpty || token.isEmpty) {
      throw WebimApiException(
        message: 'fullUpdate missing visitSessionId or authToken',
      );
    }

    String? parsedVisitorJson;
    final visitor = fullUpdate['visitor'];
    if (visitor is String && visitor.isNotEmpty) {
      parsedVisitorJson = visitor;
    } else if (visitor is Map<String, dynamic>) {
      parsedVisitorJson = jsonEncode(visitor);
    }

    return Session(
      sessionId: sessionId,
      token: token,
      pageId: pageId.isEmpty ? null : pageId,
      visitorJsonString: parsedVisitorJson,
    );
  }

  @override
  Future<void> destroy({required String sessionId}) async {
    // Swift: SessionDestroyer only runs local actions (stop loops, clear Keychain).
    // No Webim endpoint for "delete session"; optional closeChat() is separate.
  }
}
