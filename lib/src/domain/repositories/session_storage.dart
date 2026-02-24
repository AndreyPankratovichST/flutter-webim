import 'package:webim/src/domain/entities/stored_session_data.dart';

/// Special key to store last account name (for visitorDataClearingEnabled).
const String kLastAccountStorageKey = '__last_account__';

/// Abstraction for persisting session data (Swift: WMKeychainWrapper).
/// App can implement with flutter_secure_storage or shared_preferences.
abstract class SessionStorage {
  /// Saves session data under [key] (e.g. accountName_location_mobileChatInstance).
  Future<void> save(String key, StoredSessionData data);

  /// Loads session data for [key]; null if none or invalid.
  Future<StoredSessionData?> load(String key);

  /// Clears data for [key] (e.g. on destroy or visitorDataClearing).
  Future<void> clear(String key);

  /// Clears all stored session data (e.g. when accountName changes and visitorDataClearingEnabled).
  Future<void> clearAll();

  /// Last stored account name; null if none. Used to clear on account change.
  Future<String?> getLastAccount();

  /// Stores current account name (called after successful session save).
  Future<void> setLastAccount(String accountName);
}
