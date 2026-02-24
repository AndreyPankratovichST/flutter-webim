import 'dart:convert';

/// Data persisted for session restore (Swift: Keychain session_id, page_id, auth_token, visitor).
class StoredSessionData {
  final String? visitSessionId;
  final String? pageId;
  final String? authToken;
  final String? visitorJsonString;

  const StoredSessionData({
    this.visitSessionId,
    this.pageId,
    this.authToken,
    this.visitorJsonString,
  });

  Map<String, dynamic> toJson() => {
        'visitSessionId': visitSessionId,
        'pageId': pageId,
        'authToken': authToken,
        'visitorJsonString': visitorJsonString,
      };

  factory StoredSessionData.fromJson(Map<String, dynamic> json) {
    return StoredSessionData(
      visitSessionId: json['visitSessionId'] as String?,
      pageId: json['pageId'] as String?,
      authToken: json['authToken'] as String?,
      visitorJsonString: json['visitorJsonString'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static StoredSessionData? fromJsonString(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return StoredSessionData.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
