import '../../../../src/domain/entities/message.dart';

/// Repository for message operations.
abstract class MessageRepository {
  /// Sends a new message. Returns the sent [Message].
  Future<Message> send({required String sessionId, required String content, required String type});

  /// Fetches paginated chat history for a session.
  Future<List<Message>> fetchHistory({required String sessionId, int? limit, DateTime? before, DateTime? since});

  /// Subscribes to real‑time message stream for a session.
  Stream<Message> listen({required String sessionId});
}
