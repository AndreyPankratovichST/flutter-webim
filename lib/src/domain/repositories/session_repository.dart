import 'package:webim/src/domain/entities/session.dart';

abstract class SessionRepository {
  /// GET /l/v/m/init; returns Session from fullUpdate (visitSessionId, authToken, pageId).
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
  });

  Future<void> destroy({required String sessionId});
}
