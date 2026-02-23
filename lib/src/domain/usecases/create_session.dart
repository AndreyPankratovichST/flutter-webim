import 'package:webim/src/domain/entities/session.dart';
import 'package:webim/src/domain/repositories/session_repository.dart';

/// Use‑case for creating a new visitor session.
class CreateSession {
  final SessionRepository _repo;

  const CreateSession(this._repo);

  Future<Session> call({
    required String visitorId,
    required String clientSideId,
  }) => _repo.create(visitorId: visitorId, clientSideId: clientSideId);
}
