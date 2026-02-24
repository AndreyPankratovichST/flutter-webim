import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'webim_session_database.g.dart';

class SessionEntries extends Table {
  TextColumn get key => text()();
  TextColumn get visitSessionId => text().nullable()();
  TextColumn get pageId => text().nullable()();
  TextColumn get authToken => text().nullable()();
  TextColumn get visitorJsonString => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [SessionEntries])
class WebimSessionDatabase extends _$WebimSessionDatabase {
  WebimSessionDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  /// Opens a database at [path] (e.g. from getApplicationDocumentsDirectory).
  factory WebimSessionDatabase.fromPath(String path) {
    return WebimSessionDatabase(
      LazyDatabase(() => NativeDatabase(File(path))),
    );
  }
}
