import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/domain/entities/session.dart';
import 'package:webim/src/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final ApiClient _client;

  SessionRepositoryImpl(this._client);

  @override
  Future<Session> create({
    required String visitorId,
    required String clientSideId,
  }) async {
    final body = {'visitorId': visitorId, 'clientSideId': clientSideId};
    final json = await _client.post('/session/create', body: body);
    return Session.fromJson(json);
  }

  @override
  Future<Session> refresh({required String token}) async {
    final body = {'token': token};
    final json = await _client.post('/session/refresh', body: body);
    return Session.fromJson(json);
  }

  @override
  Future<void> destroy({required String sessionId}) async {
    await _client.delete(
      '/session/delete',
      headers: {'Authorization': 'Bearer $sessionId'},
    );
  }
}
