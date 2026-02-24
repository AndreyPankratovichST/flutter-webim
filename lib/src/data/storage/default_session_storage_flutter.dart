import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:webim/src/data/storage/create_session_storage.dart';
import 'package:webim/src/data/storage/in_memory_session_storage.dart';
import 'package:webim/src/domain/entities/webim.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

void _registerDefaultStorage() {
  Webim.defaultSessionStorageGetter = getDefaultSessionStorage;
}

/// Ensures [Webim.defaultSessionStorageGetter] is set. Call from [WebimSessionImpl.build]
/// so the default (cached) storage is used when [setSessionStorage] was not called.
void ensureDefaultStorageRegistered() {
  if (Webim.defaultSessionStorageGetter == null) {
    _registerDefaultStorage();
  }
}

SessionStorage? _defaultSessionStorage;
Future<SessionStorage>? _defaultSessionStorageFuture;

/// Returns a cached [SessionStorage] suitable for the current platform:
/// - **Web**: in-memory (no path_provider/platform channel).
/// - **VM/IO**: Drift (SQLite) at a path from [getApplicationDocumentsDirectory].
///
/// One instance per app (lazy). For Flutter apps. Import `package:webim/webim.dart`.
Future<SessionStorage> getDefaultSessionStorage() async {
  if (_defaultSessionStorage != null) return _defaultSessionStorage!;
  _defaultSessionStorageFuture ??= _createDefaultSessionStorage();
  _defaultSessionStorage = await _defaultSessionStorageFuture!;
  return _defaultSessionStorage!;
}

Future<SessionStorage> _createDefaultSessionStorage() async {
  final path = kIsWeb
      ? 'webim_session'
      : '${(await getApplicationDocumentsDirectory()).path}/webim_sessions.db';
  return createSessionStorageFromPath(path) ?? InMemorySessionStorage();
}
