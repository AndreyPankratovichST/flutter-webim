/// Session data from server (GET /l/v/m/init fullUpdate: visitSessionId, authToken, pageId, visitor).
class Session {
  final String sessionId;
  final String token;
  /// Required for Webim API: delta and action requests use page-id and auth-token.
  final String? pageId;
  /// Visitor JSON from fullUpdate (for persistence / restore).
  final String? visitorJsonString;
  final String? visitorId;
  final String? clientSideId;

  const Session({
    required this.sessionId,
    required this.token,
    this.pageId,
    this.visitorJsonString,
    this.visitorId,
    this.clientSideId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final sessionId = json['sessionId'] as String? ?? json['id'] as String? ?? json['visitSessionId'] as String? ?? '';
    final token = json['token'] as String? ?? json['authToken'] as String? ?? '';
    final pageId = json['pageId'] as String? ?? json['page_id'] as String?;
    return Session(
      sessionId: sessionId,
      token: token,
      pageId: pageId,
      visitorJsonString: json['visitorJsonString'] as String?,
      visitorId: json['visitorId'] as String?,
      clientSideId: json['clientSideId'] as String?,
    );
  }
}
