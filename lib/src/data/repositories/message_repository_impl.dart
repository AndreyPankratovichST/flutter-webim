import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final ApiClient _client;
  final String _wsBaseUrl;

  MessageRepositoryImpl(this._client, this._wsBaseUrl);

  @override
  Future<Message> send({
    required String sessionId,
    required String content,
    required String type,
  }) async {
    final body = {'sessionId': sessionId, 'content': content, 'type': type};
    final json = await _client.post('/message/send', body: body);
    return Message.fromJson(json);
  }

  @override
  Future<List<Message>> fetchHistory({
    required String sessionId,
    int? limit,
    DateTime? before,
    DateTime? since,
  }) async {
    final query = <String, dynamic>{'sessionId': sessionId};
    if (limit != null) query['limit'] = limit;
    if (before != null) query['before'] = before.toIso8601String();
    if (since != null) query['since'] = since.toIso8601String();
    final json = await _client.get('/message/history', query: query);
    final messages = (json['messages'] as List<dynamic>)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    return messages;
  }

  @override
  Stream<Message> listen({required String sessionId}) {
    final uri = Uri.parse('$_wsBaseUrl/message/stream?sessionId=$sessionId');
    final channel = WebSocketChannel.connect(uri);
    return channel.stream.map(
      (data) => Message.fromJson(data as Map<String, dynamic>),
    );
  }
}
