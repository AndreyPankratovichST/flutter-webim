import 'package:drift/drift.dart';
import 'package:webim/src/data/storage/webim_session_database.dart';
import 'package:webim/src/domain/entities/stored_session_data.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

/// [SessionStorage] implementation using Drift (SQLite).
/// Use [WebimSessionDatabase.fromPath] to open a database file.
class DriftSessionStorage implements SessionStorage {
  DriftSessionStorage(this._db);

  final WebimSessionDatabase _db;

  @override
  Future<void> save(String key, StoredSessionData data) async {
    await _db.into(_db.sessionEntries).insertOnConflictUpdate(
          SessionEntriesCompanion.insert(
            key: key,
            visitSessionId: Value(data.visitSessionId),
            pageId: Value(data.pageId),
            authToken: Value(data.authToken),
            visitorJsonString: Value(data.visitorJsonString),
          ),
        );
  }

  @override
  Future<StoredSessionData?> load(String key) async {
    final row = await (_db.select(_db.sessionEntries)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    return StoredSessionData(
      visitSessionId: row.visitSessionId,
      pageId: row.pageId,
      authToken: row.authToken,
      visitorJsonString: row.visitorJsonString,
    );
  }

  @override
  Future<void> clear(String key) async {
    await (_db.delete(_db.sessionEntries)..where((t) => t.key.equals(key)))
        .go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.sessionEntries).go();
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
