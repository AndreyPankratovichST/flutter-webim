import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/repositories/message_repository.dart';

class ListenMessages {
  final MessageRepository _repo;

  const ListenMessages(this._repo);

  Stream<Message> call({required String sessionId}) =>
      _repo.listen(sessionId: sessionId);
}
