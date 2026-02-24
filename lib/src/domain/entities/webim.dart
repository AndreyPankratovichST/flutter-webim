import 'package:webim/src/domain/entities/faq_builder.dart';
import 'package:webim/src/domain/entities/session_builder.dart';
import 'package:webim/src/domain/entities/webim_remote_notification.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

/// Main entry point for Webim SDK. See Webim.swift.
abstract class Webim {
  Webim._();

  /// Optional default session storage (e.g. set by `package:webim/flutter.dart`).
  /// When set and [SessionBuilder.build] is called without [SessionBuilder.setSessionStorage],
  /// this getter is used.
  static Future<SessionStorage> Function()? defaultSessionStorageGetter;

  /// Returns new SessionBuilder for creating WebimSession.
  static SessionBuilder newSessionBuilder() => SessionBuilder();

  /// Returns new FAQBuilder for creating FAQ.
  static FAQBuilder newFAQBuilder() => FAQBuilder();

  /// Parses APNs userInfo into Webim remote notification. Use [visitorId] to filter by current visitor.
  /// See Webim.parse(remoteNotification:visitorId:) (Swift).
  static WebimRemoteNotification? parse(
    Map<String, dynamic> remoteNotification, {
    String? visitorId,
  }) {
    final notification = WebimRemoteNotification.fromUserInfo(remoteNotification);
    if (notification == null) return null;
    if (visitorId == null) return notification;
    final params = notification.parameters;
    final indexOfId = switch (notification.type) {
      NotificationType.operatorAccepted => 1,
      NotificationType.operatorFile => 2,
      NotificationType.operatorMessage => 2,
      _ => 0,
    };
    if (params.length <= indexOfId) return notification;
    return params[indexOfId] == visitorId ? notification : null;
  }

  /// Returns true if [remoteNotification] userInfo is from Webim (has "webim": true).
  /// See Webim.isWebim(remoteNotification:) (Swift).
  static bool isWebim(Map<String, dynamic> remoteNotification) {
    return remoteNotification['webim'] == true;
  }
}
