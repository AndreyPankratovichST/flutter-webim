import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/repositories/message_repository.dart';

class FetchHistory {
  final MessageRepository _repo;

  const FetchHistory(this._repo);

  Future<List<Message>> call({
    required String sessionId,
    int? limit,
    DateTime? before,
    DateTime? since,
  }) => _repo.fetchHistory(
    sessionId: sessionId,
    limit: limit,
    before: before,
    since: since,
  );
}
