// Export for VM/IO only. Do not import from web — use createSessionStorageFromPath
// or a custom SessionStorage instead (avoids pulling in sqlite3/FFI).
library webim_native_storage;

export 'src/data/storage/webim_session_database.dart';
export 'src/data/storage/drift_session_storage.dart';
