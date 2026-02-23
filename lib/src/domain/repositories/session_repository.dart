import 'package:webim/src/domain/entities/session.dart';

abstract class SessionRepository {

  Future<Session> create({required String visitorId, required String clientSideId});

  Future<Session> refresh({required String token});

  Future<void> destroy({required String sessionId});
}
