import 'package:webim/src/data/storage/drift_session_storage.dart';
import 'package:webim/src/data/storage/webim_session_database.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

/// Creates [SessionStorage] from file path (VM/IO). Uses Drift (SQLite).
SessionStorage? createSessionStorageFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  return DriftSessionStorage(WebimSessionDatabase.fromPath(path));
}
