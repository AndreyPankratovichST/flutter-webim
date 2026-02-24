import 'package:webim/src/domain/entities/stored_session_data.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

/// Simple [SessionStorage] in RAM. Suited for web where SQLite/FFI is unavailable.
/// Data is lost on page reload. For persistent web storage, provide a custom
/// [SessionStorage] (e.g. backed by localStorage).
class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> save(String key, StoredSessionData data) async {
    _store[key] = data.toJsonString();
  }

  @override
  Future<StoredSessionData?> load(String key) async {
    final s = _store[key];
    return StoredSessionData.fromJsonString(s);
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
    final data = await load(kLastAccountStorageKey);
    return data?.visitSessionId;
  }

  @override
  Future<void> setLastAccount(String accountName) async {
    await save(
      kLastAccountStorageKey,
      StoredSessionData(visitSessionId: accountName),
    );
  }
}
