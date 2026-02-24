import 'package:webim/src/domain/entities/message.dart';

/// Repository for message operations.
abstract class MessageRepository {
  /// Sends a new message. Returns the message ID (clientSideId).
  /// If [clientSideId] is null, one will be generated.
  Future<String> send({
    required String sessionId,
    required String content,
    required String type,
    String? clientSideId,
  });

  /// Fetches paginated chat history for a session.
  Future<List<Message>> fetchHistory({required String sessionId, int? limit, DateTime? before, DateTime? since});

  /// Subscribes to real‑time message stream for a session.
  Stream<Message> listen({required String sessionId});

  /// Fetches delta updates (fullUpdate/deltaList). EndpointDoc: GET /history/delta?sessionId=&since=.
  Future<Map<String, dynamic>> getDelta({required String sessionId, String? since});
}
