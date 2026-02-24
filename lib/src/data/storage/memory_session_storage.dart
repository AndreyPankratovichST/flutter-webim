import 'package:webim/src/domain/entities/stored_session_data.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

/// In-memory SessionStorage (for tests or single-run; no persistence across restarts).
class MemorySessionStorage implements SessionStorage {
  final Map<String, StoredSessionData> _store = {};

  @override
  Future<void> save(String key, StoredSessionData data) async {
    _store[key] = data;
  }

  @override
  Future<StoredSessionData?> load(String key) async {
    return _store[key];
  }

  @override
  Future<void> clear(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
  }

  @override
  Future<String?> getLastAccount() async {
    return _store[kLastAccountStorageKey]?.visitSessionId;
  }

  @override
  Future<void> setLastAccount(String accountName) async {
    _store[kLastAccountStorageKey] =
        StoredSessionData(visitSessionId: accountName);
  }
}
