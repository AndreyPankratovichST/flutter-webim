import 'package:webim/src/data/storage/in_memory_session_storage.dart';
import 'package:webim/src/domain/repositories/session_storage.dart';

/// Creates [SessionStorage] for web. Uses in-memory storage (no persistence across reloads).
/// For persistent web storage, pass a custom [SessionStorage] to the session builder.
SessionStorage? createSessionStorageFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  return InMemorySessionStorage();
}
