// Conditional: VM/IO uses Drift (SQLite), web uses in-memory. Stub for other platforms.
export 'create_session_storage_stub.dart'
  if (dart.library.ffi) 'create_session_storage_io.dart'
  if (dart.library.js_interop) 'create_session_storage_web.dart';
