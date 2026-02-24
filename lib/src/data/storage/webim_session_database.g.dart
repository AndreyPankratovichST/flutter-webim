// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webim_session_database.dart';

// ignore_for_file: type=lint
class $SessionEntriesTable extends SessionEntries
    with TableInfo<$SessionEntriesTable, SessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitSessionIdMeta = const VerificationMeta(
    'visitSessionId',
  );
  @override
  late final GeneratedColumn<String> visitSessionId = GeneratedColumn<String>(
    'visit_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authTokenMeta = const VerificationMeta(
    'authToken',
  );
  @override
  late final GeneratedColumn<String> authToken = GeneratedColumn<String>(
    'auth_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitorJsonStringMeta = const VerificationMeta(
    'visitorJsonString',
  );
  @override
  late final GeneratedColumn<String> visitorJsonString =
      GeneratedColumn<String>(
        'visitor_json_string',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    visitSessionId,
    pageId,
    authToken,
    visitorJsonString,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('visit_session_id')) {
      context.handle(
        _visitSessionIdMeta,
        visitSessionId.isAcceptableOrUnknown(
          data['visit_session_id']!,
          _visitSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    }
    if (data.containsKey('auth_token')) {
      context.handle(
        _authTokenMeta,
        authToken.isAcceptableOrUnknown(data['auth_token']!, _authTokenMeta),
      );
    }
    if (data.containsKey('visitor_json_string')) {
      context.handle(
        _visitorJsonStringMeta,
        visitorJsonString.isAcceptableOrUnknown(
          data['visitor_json_string']!,
          _visitorJsonStringMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      visitSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_session_id'],
      ),
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      ),
      authToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_token'],
      ),
      visitorJsonString: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visitor_json_string'],
      ),
    );
  }

  @override
  $SessionEntriesTable createAlias(String alias) {
    return $SessionEntriesTable(attachedDatabase, alias);
  }
}

class SessionEntry extends DataClass implements Insertable<SessionEntry> {
  final String key;
  final String? visitSessionId;
  final String? pageId;
  final String? authToken;
  final String? visitorJsonString;
  const SessionEntry({
    required this.key,
    this.visitSessionId,
    this.pageId,
    this.authToken,
    this.visitorJsonString,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || visitSessionId != null) {
      map['visit_session_id'] = Variable<String>(visitSessionId);
    }
    if (!nullToAbsent || pageId != null) {
      map['page_id'] = Variable<String>(pageId);
    }
    if (!nullToAbsent || authToken != null) {
      map['auth_token'] = Variable<String>(authToken);
    }
    if (!nullToAbsent || visitorJsonString != null) {
      map['visitor_json_string'] = Variable<String>(visitorJsonString);
    }
    return map;
  }

  SessionEntriesCompanion toCompanion(bool nullToAbsent) {
    return SessionEntriesCompanion(
      key: Value(key),
      visitSessionId: visitSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitSessionId),
      pageId: pageId == null && nullToAbsent
          ? const Value.absent()
          : Value(pageId),
      authToken: authToken == null && nullToAbsent
          ? const Value.absent()
          : Value(authToken),
      visitorJsonString: visitorJsonString == null && nullToAbsent
          ? const Value.absent()
          : Value(visitorJsonString),
    );
  }

  factory SessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEntry(
      key: serializer.fromJson<String>(json['key']),
      visitSessionId: serializer.fromJson<String?>(json['visitSessionId']),
      pageId: serializer.fromJson<String?>(json['pageId']),
      authToken: serializer.fromJson<String?>(json['authToken']),
      visitorJsonString: serializer.fromJson<String?>(
        json['visitorJsonString'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'visitSessionId': serializer.toJson<String?>(visitSessionId),
      'pageId': serializer.toJson<String?>(pageId),
      'authToken': serializer.toJson<String?>(authToken),
      'visitorJsonString': serializer.toJson<String?>(visitorJsonString),
    };
  }

  SessionEntry copyWith({
    String? key,
    Value<String?> visitSessionId = const Value.absent(),
    Value<String?> pageId = const Value.absent(),
    Value<String?> authToken = const Value.absent(),
    Value<String?> visitorJsonString = const Value.absent(),
  }) => SessionEntry(
    key: key ?? this.key,
    visitSessionId: visitSessionId.present
        ? visitSessionId.value
        : this.visitSessionId,
    pageId: pageId.present ? pageId.value : this.pageId,
    authToken: authToken.present ? authToken.value : this.authToken,
    visitorJsonString: visitorJsonString.present
        ? visitorJsonString.value
        : this.visitorJsonString,
  );
  SessionEntry copyWithCompanion(SessionEntriesCompanion data) {
    return SessionEntry(
      key: data.key.present ? data.key.value : this.key,
      visitSessionId: data.visitSessionId.present
          ? data.visitSessionId.value
          : this.visitSessionId,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      authToken: data.authToken.present ? data.authToken.value : this.authToken,
      visitorJsonString: data.visitorJsonString.present
          ? data.visitorJsonString.value
          : this.visitorJsonString,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntry(')
          ..write('key: $key, ')
          ..write('visitSessionId: $visitSessionId, ')
          ..write('pageId: $pageId, ')
          ..write('authToken: $authToken, ')
          ..write('visitorJsonString: $visitorJsonString')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, visitSessionId, pageId, authToken, visitorJsonString);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEntry &&
          other.key == this.key &&
          other.visitSessionId == this.visitSessionId &&
          other.pageId == this.pageId &&
          other.authToken == this.authToken &&
          other.visitorJsonString == this.visitorJsonString);
}

class SessionEntriesCompanion extends UpdateCompanion<SessionEntry> {
  final Value<String> key;
  final Value<String?> visitSessionId;
  final Value<String?> pageId;
  final Value<String?> authToken;
  final Value<String?> visitorJsonString;
  final Value<int> rowid;
  const SessionEntriesCompanion({
    this.key = const Value.absent(),
    this.visitSessionId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.authToken = const Value.absent(),
    this.visitorJsonString = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionEntriesCompanion.insert({
    required String key,
    this.visitSessionId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.authToken = const Value.absent(),
    this.visitorJsonString = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SessionEntry> custom({
    Expression<String>? key,
    Expression<String>? visitSessionId,
    Expression<String>? pageId,
    Expression<String>? authToken,
    Expression<String>? visitorJsonString,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (visitSessionId != null) 'visit_session_id': visitSessionId,
      if (pageId != null) 'page_id': pageId,
      if (authToken != null) 'auth_token': authToken,
      if (visitorJsonString != null) 'visitor_json_string': visitorJsonString,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionEntriesCompanion copyWith({
    Value<String>? key,
    Value<String?>? visitSessionId,
    Value<String?>? pageId,
    Value<String?>? authToken,
    Value<String?>? visitorJsonString,
    Value<int>? rowid,
  }) {
    return SessionEntriesCompanion(
      key: key ?? this.key,
      visitSessionId: visitSessionId ?? this.visitSessionId,
      pageId: pageId ?? this.pageId,
      authToken: authToken ?? this.authToken,
      visitorJsonString: visitorJsonString ?? this.visitorJsonString,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (visitSessionId.present) {
      map['visit_session_id'] = Variable<String>(visitSessionId.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (authToken.present) {
      map['auth_token'] = Variable<String>(authToken.value);
    }
    if (visitorJsonString.present) {
      map['visitor_json_string'] = Variable<String>(visitorJsonString.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntriesCompanion(')
          ..write('key: $key, ')
          ..write('visitSessionId: $visitSessionId, ')
          ..write('pageId: $pageId, ')
          ..write('authToken: $authToken, ')
          ..write('visitorJsonString: $visitorJsonString, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$WebimSessionDatabase extends GeneratedDatabase {
  _$WebimSessionDatabase(QueryExecutor e) : super(e);
  $WebimSessionDatabaseManager get managers =>
      $WebimSessionDatabaseManager(this);
  late final $SessionEntriesTable sessionEntries = $SessionEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessionEntries];
}

typedef $$SessionEntriesTableCreateCompanionBuilder =
    SessionEntriesCompanion Function({
      required String key,
      Value<String?> visitSessionId,
      Value<String?> pageId,
      Value<String?> authToken,
      Value<String?> visitorJsonString,
      Value<int> rowid,
    });
typedef $$SessionEntriesTableUpdateCompanionBuilder =
    SessionEntriesCompanion Function({
      Value<String> key,
      Value<String?> visitSessionId,
      Value<String?> pageId,
      Value<String?> authToken,
      Value<String?> visitorJsonString,
      Value<int> rowid,
    });

class $$SessionEntriesTableFilterComposer
    extends Composer<_$WebimSessionDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitSessionId => $composableBuilder(
    column: $table.visitSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authToken => $composableBuilder(
    column: $table.authToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitorJsonString => $composableBuilder(
    column: $table.visitorJsonString,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionEntriesTableOrderingComposer
    extends Composer<_$WebimSessionDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitSessionId => $composableBuilder(
    column: $table.visitSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authToken => $composableBuilder(
    column: $table.authToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitorJsonString => $composableBuilder(
    column: $table.visitorJsonString,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionEntriesTableAnnotationComposer
    extends Composer<_$WebimSessionDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get visitSessionId => $composableBuilder(
    column: $table.visitSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get authToken =>
      $composableBuilder(column: $table.authToken, builder: (column) => column);

  GeneratedColumn<String> get visitorJsonString => $composableBuilder(
    column: $table.visitorJsonString,
    builder: (column) => column,
  );
}

class $$SessionEntriesTableTableManager
    extends
        RootTableManager<
          _$WebimSessionDatabase,
          $SessionEntriesTable,
          SessionEntry,
          $$SessionEntriesTableFilterComposer,
          $$SessionEntriesTableOrderingComposer,
          $$SessionEntriesTableAnnotationComposer,
          $$SessionEntriesTableCreateCompanionBuilder,
          $$SessionEntriesTableUpdateCompanionBuilder,
          (
            SessionEntry,
            BaseReferences<
              _$WebimSessionDatabase,
              $SessionEntriesTable,
              SessionEntry
            >,
          ),
          SessionEntry,
          PrefetchHooks Function()
        > {
  $$SessionEntriesTableTableManager(
    _$WebimSessionDatabase db,
    $SessionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> visitSessionId = const Value.absent(),
                Value<String?> pageId = const Value.absent(),
                Value<String?> authToken = const Value.absent(),
                Value<String?> visitorJsonString = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEntriesCompanion(
                key: key,
                visitSessionId: visitSessionId,
                pageId: pageId,
                authToken: authToken,
                visitorJsonString: visitorJsonString,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> visitSessionId = const Value.absent(),
                Value<String?> pageId = const Value.absent(),
                Value<String?> authToken = const Value.absent(),
                Value<String?> visitorJsonString = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEntriesCompanion.insert(
                key: key,
                visitSessionId: visitSessionId,
                pageId: pageId,
                authToken: authToken,
                visitorJsonString: visitorJsonString,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WebimSessionDatabase,
      $SessionEntriesTable,
      SessionEntry,
      $$SessionEntriesTableFilterComposer,
      $$SessionEntriesTableOrderingComposer,
      $$SessionEntriesTableAnnotationComposer,
      $$SessionEntriesTableCreateCompanionBuilder,
      $$SessionEntriesTableUpdateCompanionBuilder,
      (
        SessionEntry,
        BaseReferences<
          _$WebimSessionDatabase,
          $SessionEntriesTable,
          SessionEntry
        >,
      ),
      SessionEntry,
      PrefetchHooks Function()
    >;

class $WebimSessionDatabaseManager {
  final _$WebimSessionDatabase _db;
  $WebimSessionDatabaseManager(this._db);
  $$SessionEntriesTableTableManager get sessionEntries =>
      $$SessionEntriesTableTableManager(_db, _db.sessionEntries);
}
