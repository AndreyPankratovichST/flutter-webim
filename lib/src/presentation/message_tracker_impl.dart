import 'package:webim/src/data/repositories/message_repository_impl.dart';
import 'package:webim/src/domain/entities/access_error.dart';
import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/entities/message_listener.dart';
import 'package:webim/src/domain/entities/message_tracker.dart';

/// Implementation of MessageTracker. Uses MessageRepository for history.
class MessageTrackerImpl implements MessageTracker {
  MessageTrackerImpl(
    this._messageRepo,
    this._sessionId,
    this._listener,
  );

  final MessageRepositoryImpl _messageRepo;
  final String _sessionId;
  final MessageListener _listener;

  bool _destroyed = false;
  DateTime? _oldestTimestamp;
  Message? _lastMessage;

  void _checkNotDestroyed() {
    if (_destroyed) throw AccessError.invalidSession;
  }

  @override
  void getLastMessages(int limit, void Function(List<Message>) completion) {
    _checkNotDestroyed();
    if (limit < 1) {
      completion([]);
      return;
    }
    _messageRepo
        .fetchHistory(sessionId: _sessionId, limit: limit)
        .then((list) {
          if (_destroyed) {
            completion([]);
            return;
          }
          if (list.isNotEmpty) {
            final oldest = list.last.timestamp;
            if (oldest != null) _oldestTimestamp = oldest;
          }
          for (var i = 0; i < list.length; i++) {
            _listener.added(list[i], i > 0 ? list[i - 1] : null);
          }
          _lastMessage = list.isNotEmpty ? list.last : null;
          completion(list);
        })
        .catchError((_) {
          completion([]);
        });
  }

  /// Pushes a message received from delta (CHAT_MESSAGE add) to the listener.
  void pushMessageFromDelta(Message message) {
    if (_destroyed) return;
    _listener.added(message, _lastMessage);
    _lastMessage = message;
  }

  @override
  void getNextMessages(int limit, void Function(List<Message>) completion) {
    _checkNotDestroyed();
    if (limit < 1) {
      completion([]);
      return;
    }
    final before = _oldestTimestamp;
    if (before == null) {
      completion([]);
      return;
    }
    _messageRepo
        .fetchHistory(sessionId: _sessionId, limit: limit, before: before)
        .then((list) {
          if (_destroyed) {
            completion([]);
            return;
          }
          if (list.isNotEmpty) {
            final oldest = list.last.timestamp;
            if (oldest != null) _oldestTimestamp = oldest;
          }
          for (var i = 0; i < list.length; i++) {
            _listener.added(list[i], i > 0 ? list[i - 1] : null);
          }
          _lastMessage = list.isNotEmpty ? list.last : null;
          completion(list);
        })
        .catchError((_) {
          completion([]);
        });
  }

  @override
  void getAllMessages(void Function(List<Message>) completion) {
    _checkNotDestroyed();
    _messageRepo
        .fetchHistory(sessionId: _sessionId, limit: 1000)
        .then((list) {
          if (_destroyed) {
            completion([]);
            return;
          }
          if (list.isNotEmpty) _oldestTimestamp = list.last.timestamp;
          for (var i = 0; i < list.length; i++) {
            _listener.added(list[i], i > 0 ? list[i - 1] : null);
          }
          _lastMessage = list.isNotEmpty ? list.last : null;
          completion(list);
        })
        .catchError((_) {
          completion([]);
        });
  }

  @override
  void resetTo(Message message) {
    _checkNotDestroyed();
    _oldestTimestamp = message.timestamp;
  }

  @override
  void destroy() {
    _destroyed = true;
  }
}
