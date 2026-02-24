import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/entities/message_send_status.dart';
import 'package:webim/src/domain/repositories/message_repository.dart';

class SendMessage {
  final MessageRepository _repo;

  const SendMessage(this._repo);

  Future<Message> call({
    required String sessionId,
    required String content,
    required String type,
    String? clientSideId,
  }) async {
    final id = await _repo.send(
      sessionId: sessionId,
      content: content,
      type: type,
      clientSideId: clientSideId,
    );
    return Message(
      id: id,
      text: content,
      sendStatus: MessageSendStatus.sent,
    );
  }
}
