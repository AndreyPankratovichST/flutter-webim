import 'package:webim/src/domain/repositories/session_repository.dart';

class DestroySession {
  final SessionRepository _repo;

  const DestroySession(this._repo);

  Future<void> call({required String sessionId}) => _repo.destroy(sessionId: sessionId);
}
