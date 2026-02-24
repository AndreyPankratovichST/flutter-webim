import 'package:webim/src/domain/repositories/session_storage.dart';

/// Creates default [SessionStorage] from path. Unsupported on this platform.
SessionStorage? createSessionStorageFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  throw UnsupportedError(
    'Creating session storage from path is not supported on this platform. '
    'Provide a custom SessionStorage (e.g. InMemorySessionStorage on web).',
  );
}
