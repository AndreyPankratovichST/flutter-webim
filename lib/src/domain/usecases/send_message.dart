import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/repositories/message_repository.dart';

class SendMessage {
  final MessageRepository _repo;

  const SendMessage(this._repo);

  Future<Message> call({
    required String sessionId,
    required String content,
    required String type,
  }) => _repo.send(sessionId: sessionId, content: content, type: type);
}
