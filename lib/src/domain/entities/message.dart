import 'package:webim/src/domain/entities/group.dart';
import 'package:webim/src/domain/entities/keyboard.dart';
import 'package:webim/src/domain/entities/keyboard_request.dart';
import 'package:webim/src/domain/entities/message_data.dart';
import 'package:webim/src/domain/entities/message_send_status.dart';
import 'package:webim/src/domain/entities/message_type.dart';
import 'package:webim/src/domain/entities/quote.dart';
import 'package:webim/src/domain/entities/sticker.dart';

/// Single message in history. Immutable.
/// See Message.swift, MessageItem.swift (id, authorId, avatar, text, ts/ts_m, kind, chatId, quote, data, etc.).
class Message {
  /// Unique ID (clientSideId if sending, else server id).
  final String id;
  final String? serverSideID;
  final String? currentChatID;
  final String text;
  final DateTime? timestamp;
  final MessageSendStatus sendStatus;
  final String? operatorID;
  final String senderName;
  final String? senderAvatarFullURL;
  final Map<String, dynamic>? rawData;
  final bool canBeEdited;
  final bool canBeReplied;
  final bool isEdited;
  final bool read;
  final String? reaction;
  final bool canVisitorReact;
  final bool canVisitorChangeReaction;
  final MessageType messageType;
  final Quote? quote;
  final MessageData? data;
  final Sticker? sticker;
  final Keyboard? keyboard;
  final KeyboardRequest? keyboardRequest;
  final bool? isDeleted;
  final Group? group;

  const Message({
    required this.id,
    this.serverSideID,
    this.currentChatID,
    this.text = '',
    this.timestamp,
    this.sendStatus = MessageSendStatus.sent,
    this.operatorID,
    this.senderName = '',
    this.senderAvatarFullURL,
    this.rawData,
    this.canBeEdited = false,
    this.canBeReplied = false,
    this.isEdited = false,
    this.read = false,
    this.reaction,
    this.canVisitorReact = false,
    this.canVisitorChangeReaction = false,
    this.messageType = MessageType.unknown,
    this.quote,
    this.data,
    this.sticker,
    this.keyboard,
    this.keyboardRequest,
    this.isDeleted,
    this.group,
  });

  /// MessageItem JSON: authorId, avatar, canBeEdited, canBeReplied, chatId, clientSideId, data, deleted, id (server), edited, kind, quote, read, name, text, ts_m, ts, reaction, canVisitorReact, canVisitorChangeReaction.
  factory Message.fromJson(Map<String, dynamic> json) {
    final serverSideID = json['id'] as String?;
    final clientSideID = json['clientSideId'] as String?;
    final id = clientSideID ?? serverSideID ?? '';
    final tsM = json['ts_m'] as int?;
    final ts = json['ts'] as num?;
    DateTime? timestamp;
    if (tsM != null && tsM > 0) {
      timestamp = DateTime.fromMicrosecondsSinceEpoch(tsM);
    } else if (ts != null) {
      timestamp = DateTime.fromMillisecondsSinceEpoch((ts * 1000).round());
    }
    final kind = json['kind'] as String?;
    final dataMap = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : null;
    Quote? quote;
    if (json['quote'] is Map) {
      quote = Quote.fromJson(Map<String, dynamic>.from(json['quote'] as Map));
    }
    final deleted = json['deleted'] as bool?;
    Group? group;
    if (dataMap != null && dataMap['group'] is Map) {
      group = Group.fromJson(Map<String, dynamic>.from(dataMap['group'] as Map));
    }
    Sticker? sticker;
    if (dataMap != null && dataMap['stickerId'] != null) {
      sticker = Sticker.fromJson(dataMap);
    }
    Keyboard? keyboard;
    if (dataMap != null && (dataMap['buttons'] != null || dataMap['state'] != null)) {
      keyboard = Keyboard.fromJson(dataMap);
    }
    KeyboardRequest? keyboardRequest;
    if (dataMap != null && (dataMap['request_message_id'] != null || dataMap['messageId'] != null)) {
      keyboardRequest = KeyboardRequest.fromJson(dataMap);
    }
    return Message(
      id: id,
      serverSideID: serverSideID,
      currentChatID: json['chatId'] as String?,
      text: json['text'] as String? ?? '',
      timestamp: timestamp,
      sendStatus: MessageSendStatus.sent,
      operatorID: (json['authorId'] as num?)?.toString(),
      senderName: json['name'] as String? ?? '',
      senderAvatarFullURL: json['avatar'] as String?,
      rawData: dataMap,
      canBeEdited: json['canBeEdited'] as bool? ?? false,
      canBeReplied: json['canBeReplied'] as bool? ?? false,
      isEdited: json['edited'] as bool? ?? false,
      read: json['read'] as bool? ?? false,
      reaction: json['reaction'] as String?,
      canVisitorReact: json['canVisitorReact'] as bool? ?? false,
      canVisitorChangeReaction: json['canVisitorChangeReaction'] as bool? ?? false,
      messageType: MessageTypeParser.fromString(kind),
      quote: quote,
      data: MessageData.fromJson(dataMap),
      sticker: sticker,
      keyboard: keyboard,
      keyboardRequest: keyboardRequest,
      isDeleted: deleted,
      group: group,
    );
  }

  /// Same as Swift isEqual(to:). Compares by id for identity.
  bool isEqual(Message other) => id == other.id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Message && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
