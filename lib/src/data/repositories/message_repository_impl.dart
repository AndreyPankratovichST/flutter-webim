import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final ApiClient _client;
  final String _wsBaseUrl;
  String? _pageId;
  String? _authToken;

  MessageRepositoryImpl(
    this._client,
    this._wsBaseUrl, [
    String? baseUrl,
    String? pageId,
    String? authToken,
  ])  : _pageId = pageId,
        _authToken = authToken;

  /// Updates auth after changeLocation (Swift: authorizationData reset then requestInitialization).
  void setAuth(String? pageId, String? authToken) {
    _pageId = pageId;
    _authToken = authToken;
  }

  Map<String, String> get _authQuery {
    final pid = _pageId;
    final tok = _authToken;
    if (pid == null || pid.isEmpty || tok == null || tok.isEmpty) {
      return {};
    }
    return {'page-id': pid, 'auth-token': tok};
  }

  @override
  Future<String> send({
    required String sessionId,
    required String content,
    required String type,
    String? clientSideId,
  }) async {
    final id = clientSideId ?? _generateClientSideId();
    final body = {
      'sessionId': sessionId,
      'content': content,
      'type': type,
      'clientSideId': id,
    };
    await _client.post('/message/send', body: body);
    return id;
  }

  static String _generateClientSideId() {
    const chars = 'abcdef0123456789';
    final r = DateTime.now().microsecondsSinceEpoch;
    return List.generate(32, (i) => chars[(r + i) % chars.length]).join();
  }

  @override
  Future<List<Message>> fetchHistory({
    required String sessionId,
    int? limit,
    DateTime? before,
    DateTime? since,
  }) async {
    final query = <String, dynamic>{..._authQuery};
    if (limit != null) query['limit'] = limit;
    if (before != null) query['before-ts'] = before.millisecondsSinceEpoch;
    if (since != null) query['since'] = since.millisecondsSinceEpoch;
    final json = await _client.get('/l/v/m/history', query: query);
    // Webim: history in data.messages (HistoryBeforeResponse / HistorySinceResponse).
    final data = json['data'];
    final raw = (data is Map ? data['messages'] : null) ??
        json['messages'] ??
        json['history'] ??
        json;
    final list = raw is List
        ? raw
        : (raw is Map
            ? (raw['messages'] as List?) ?? (raw['history'] as List?) ?? []
            : <dynamic>[]);
    return list
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<Message> listen({required String sessionId}) {
    final uri = Uri.parse('$_wsBaseUrl/message/stream?sessionId=$sessionId');
    final channel = WebSocketChannel.connect(uri);
    return channel.stream.map(
      (data) => Message.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Map<String, dynamic>> getDelta({
    required String sessionId,
    String? since,
  }) async {
    final query = <String, dynamic>{
      ..._authQuery,
      'since': since ?? '0',
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
    return _client.get('/l/v/m/delta', query: query);
  }
}
