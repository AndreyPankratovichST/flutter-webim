/// Type of Webim remote notification. See NotificationType (Swift).
enum NotificationType {
  contactInformationRequest,
  operatorAccepted,
  operatorFile,
  operatorMessage,
  widget,
  rateOperator,
}

/// Event of remote notification (add/delete). See NotificationEvent (Swift).
enum NotificationEvent {
  add,
  delete,
}

/// Parsed Webim remote notification (APNs userInfo). See WebimRemoteNotification (Swift).
class WebimRemoteNotification {
  const WebimRemoteNotification({
    this.type,
    this.event,
    this.parameters = const [],
    this.location,
    this.unreadByVisitorMessagesCount = 0,
  });

  final NotificationType? type;
  final NotificationEvent? event;
  final List<String> parameters;
  final String? location;
  final int unreadByVisitorMessagesCount;

  /// Parses from APNs-style userInfo. Expects aps.alert with loc-key (type), event, loc-args (parameters);
  /// top-level: webim, unread_by_visitor_msg_cnt, location. Returns null if structure invalid.
  static WebimRemoteNotification? fromUserInfo(Map<String, dynamic> userInfo) {
    final aps = userInfo['aps'];
    if (aps is! Map) return null;
    final alert = aps['alert'];
    if (alert is! Map) return null;
    final alertMap = Map<String, dynamic>.from(alert);

    final typeStr = alertMap['loc-key'] as String?;
    final notificationType = _parseType(typeStr);

    final eventStr = alertMap['event'] as String?;
    final notificationEvent = eventStr == 'add'
        ? NotificationEvent.add
        : eventStr == 'del'
            ? NotificationEvent.delete
            : null;

    final locArgs = alertMap['loc-args'];
    final parameters = locArgs is List
        ? locArgs.map((e) => e?.toString() ?? '').toList()
        : <String>[];

    final location = userInfo['location'] as String?;
    final unread = userInfo['unread_by_visitor_msg_cnt'];
    final unreadCount = unread is int ? unread : 0;

    return WebimRemoteNotification(
      type: notificationType,
      event: notificationEvent,
      parameters: parameters,
      location: location,
      unreadByVisitorMessagesCount: unreadCount,
    );
  }

  static NotificationType? _parseType(String? raw) {
    switch (raw) {
      case 'P.CR':
        return NotificationType.contactInformationRequest;
      case 'P.OA':
        return NotificationType.operatorAccepted;
      case 'P.OF':
        return NotificationType.operatorFile;
      case 'P.OM':
        return NotificationType.operatorMessage;
      case 'P.WM':
        return NotificationType.widget;
      case 'P.RO':
        return NotificationType.rateOperator;
      default:
        return null;
    }
  }
}
