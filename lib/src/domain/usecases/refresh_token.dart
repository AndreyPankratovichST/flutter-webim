import 'package:webim/src/domain/entities/session.dart';
import 'package:webim/src/domain/repositories/session_repository.dart';

class RefreshToken {
  final SessionRepository _repo;

  const RefreshToken(this._repo);

  Future<Session> call({required String token}) => _repo.refresh(token: token);
}
