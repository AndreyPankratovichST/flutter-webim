/// Department online status. See Department.getDepartmentOnlineStatus(), DepartmentOnlineStatus (Swift).
enum DepartmentOnlineStatus {
  busyOffline,
  busyOnline,
  offline,
  online,
  unknown,
}

/// Department (key, name, order, localizedNames, logo, onlineStatus).
/// See MessageStream.getDepartmentList(), DepartmentItem.swift.
class Department {
  final String key;
  final String name;
  final int order;
  final Map<String, String>? localizedNames;
  final String? logoUrl;
  final DepartmentOnlineStatus onlineStatus;

  const Department({
    required this.key,
    required this.name,
    required this.order,
    this.localizedNames,
    this.logoUrl,
    this.onlineStatus = DepartmentOnlineStatus.unknown,
  });

  /// JSON: key, name, order, localeToName, logo, online (busy_offline, busy_online, offline, online).
  static Department? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final key = json['key'] as String?;
    final name = json['name'] as String?;
    final order = json['order'] as int?;
    if (key == null || name == null || order == null) return null;
    final localeToName = json['localeToName'];
    Map<String, String>? localizedNames;
    if (localeToName is Map) {
      localizedNames = {};
      for (final e in localeToName.entries) {
        if (e.value is String) localizedNames[e.key.toString()] = e.value as String;
      }
    }
    final onlineRaw = json['online'] as String?;
    final onlineStatus = _parseOnlineStatus(onlineRaw);
    return Department(
      key: key,
      name: name,
      order: order,
      localizedNames: localizedNames?.isEmpty == true ? null : localizedNames,
      logoUrl: json['logo'] as String?,
      onlineStatus: onlineStatus,
    );
  }

  static DepartmentOnlineStatus _parseOnlineStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'busy_offline':
        return DepartmentOnlineStatus.busyOffline;
      case 'busy_online':
        return DepartmentOnlineStatus.busyOnline;
      case 'offline':
        return DepartmentOnlineStatus.offline;
      case 'online':
        return DepartmentOnlineStatus.online;
      default:
        return DepartmentOnlineStatus.unknown;
    }
  }
}
