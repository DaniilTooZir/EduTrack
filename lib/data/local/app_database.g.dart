// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalRoomsTable extends LocalRooms
    with TableInfo<$LocalRoomsTable, LocalRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, institutionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRoom(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
    );
  }

  @override
  $LocalRoomsTable createAlias(String alias) {
    return $LocalRoomsTable(attachedDatabase, alias);
  }
}

class LocalRoom extends DataClass implements Insertable<LocalRoom> {
  final String id;
  final String name;
  final String institutionId;
  const LocalRoom({
    required this.id,
    required this.name,
    required this.institutionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['institution_id'] = Variable<String>(institutionId);
    return map;
  }

  LocalRoomsCompanion toCompanion(bool nullToAbsent) {
    return LocalRoomsCompanion(
      id: Value(id),
      name: Value(name),
      institutionId: Value(institutionId),
    );
  }

  factory LocalRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRoom(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'institutionId': serializer.toJson<String>(institutionId),
    };
  }

  LocalRoom copyWith({String? id, String? name, String? institutionId}) =>
      LocalRoom(
        id: id ?? this.id,
        name: name ?? this.name,
        institutionId: institutionId ?? this.institutionId,
      );
  LocalRoom copyWithCompanion(LocalRoomsCompanion data) {
    return LocalRoom(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoom(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, institutionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRoom &&
          other.id == this.id &&
          other.name == this.name &&
          other.institutionId == this.institutionId);
}

class LocalRoomsCompanion extends UpdateCompanion<LocalRoom> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> institutionId;
  final Value<int> rowid;
  const LocalRoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRoomsCompanion.insert({
    required String id,
    required String name,
    required String institutionId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       institutionId = Value(institutionId);
  static Insertable<LocalRoom> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? institutionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (institutionId != null) 'institution_id': institutionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? institutionId,
    Value<int>? rowid,
  }) {
    return LocalRoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      institutionId: institutionId ?? this.institutionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSubjectsTable extends LocalSubjects
    with TableInfo<$LocalSubjectsTable, LocalSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, institutionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSubject(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
    );
  }

  @override
  $LocalSubjectsTable createAlias(String alias) {
    return $LocalSubjectsTable(attachedDatabase, alias);
  }
}

class LocalSubject extends DataClass implements Insertable<LocalSubject> {
  final String id;
  final String name;
  final String institutionId;
  const LocalSubject({
    required this.id,
    required this.name,
    required this.institutionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['institution_id'] = Variable<String>(institutionId);
    return map;
  }

  LocalSubjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalSubjectsCompanion(
      id: Value(id),
      name: Value(name),
      institutionId: Value(institutionId),
    );
  }

  factory LocalSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSubject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'institutionId': serializer.toJson<String>(institutionId),
    };
  }

  LocalSubject copyWith({String? id, String? name, String? institutionId}) =>
      LocalSubject(
        id: id ?? this.id,
        name: name ?? this.name,
        institutionId: institutionId ?? this.institutionId,
      );
  LocalSubject copyWithCompanion(LocalSubjectsCompanion data) {
    return LocalSubject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, institutionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSubject &&
          other.id == this.id &&
          other.name == this.name &&
          other.institutionId == this.institutionId);
}

class LocalSubjectsCompanion extends UpdateCompanion<LocalSubject> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> institutionId;
  final Value<int> rowid;
  const LocalSubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSubjectsCompanion.insert({
    required String id,
    required String name,
    required String institutionId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       institutionId = Value(institutionId);
  static Insertable<LocalSubject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? institutionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (institutionId != null) 'institution_id': institutionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? institutionId,
    Value<int>? rowid,
  }) {
    return LocalSubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      institutionId: institutionId ?? this.institutionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGroupsTable extends LocalGroups
    with TableInfo<$LocalGroupsTable, LocalGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, institutionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGroup(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
    );
  }

  @override
  $LocalGroupsTable createAlias(String alias) {
    return $LocalGroupsTable(attachedDatabase, alias);
  }
}

class LocalGroup extends DataClass implements Insertable<LocalGroup> {
  final String id;
  final String name;
  final String institutionId;
  const LocalGroup({
    required this.id,
    required this.name,
    required this.institutionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['institution_id'] = Variable<String>(institutionId);
    return map;
  }

  LocalGroupsCompanion toCompanion(bool nullToAbsent) {
    return LocalGroupsCompanion(
      id: Value(id),
      name: Value(name),
      institutionId: Value(institutionId),
    );
  }

  factory LocalGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'institutionId': serializer.toJson<String>(institutionId),
    };
  }

  LocalGroup copyWith({String? id, String? name, String? institutionId}) =>
      LocalGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        institutionId: institutionId ?? this.institutionId,
      );
  LocalGroup copyWithCompanion(LocalGroupsCompanion data) {
    return LocalGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, institutionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.institutionId == this.institutionId);
}

class LocalGroupsCompanion extends UpdateCompanion<LocalGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> institutionId;
  final Value<int> rowid;
  const LocalGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGroupsCompanion.insert({
    required String id,
    required String name,
    required String institutionId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       institutionId = Value(institutionId);
  static Insertable<LocalGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? institutionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (institutionId != null) 'institution_id': institutionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? institutionId,
    Value<int>? rowid,
  }) {
    return LocalGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      institutionId: institutionId ?? this.institutionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTeachersTable extends LocalTeachers
    with TableInfo<$LocalTeachersTable, LocalTeacher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTeachersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, surname];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_teachers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTeacher> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTeacher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTeacher(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      surname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}surname'],
          )!,
    );
  }

  @override
  $LocalTeachersTable createAlias(String alias) {
    return $LocalTeachersTable(attachedDatabase, alias);
  }
}

class LocalTeacher extends DataClass implements Insertable<LocalTeacher> {
  final String id;
  final String name;
  final String surname;
  const LocalTeacher({
    required this.id,
    required this.name,
    required this.surname,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['surname'] = Variable<String>(surname);
    return map;
  }

  LocalTeachersCompanion toCompanion(bool nullToAbsent) {
    return LocalTeachersCompanion(
      id: Value(id),
      name: Value(name),
      surname: Value(surname),
    );
  }

  factory LocalTeacher.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTeacher(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      surname: serializer.fromJson<String>(json['surname']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'surname': serializer.toJson<String>(surname),
    };
  }

  LocalTeacher copyWith({String? id, String? name, String? surname}) =>
      LocalTeacher(
        id: id ?? this.id,
        name: name ?? this.name,
        surname: surname ?? this.surname,
      );
  LocalTeacher copyWithCompanion(LocalTeachersCompanion data) {
    return LocalTeacher(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTeacher(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, surname);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTeacher &&
          other.id == this.id &&
          other.name == this.name &&
          other.surname == this.surname);
}

class LocalTeachersCompanion extends UpdateCompanion<LocalTeacher> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> surname;
  final Value<int> rowid;
  const LocalTeachersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTeachersCompanion.insert({
    required String id,
    required String name,
    required String surname,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       surname = Value(surname);
  static Insertable<LocalTeacher> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTeachersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? surname,
    Value<int>? rowid,
  }) {
    return LocalTeachersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTeachersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSchedulesTable extends LocalSchedules
    with TableInfo<$LocalSchedulesTable, LocalSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_subjects (id)',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_groups (id)',
    ),
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_teachers (id)',
    ),
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_rooms (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    institutionId,
    subjectId,
    groupId,
    teacherId,
    roomId,
    date,
    weekday,
    startTime,
    endTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSchedule(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
      subjectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}subject_id'],
          )!,
      groupId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}group_id'],
          )!,
      teacherId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}teacher_id'],
          )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      weekday:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}weekday'],
          )!,
      startTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}start_time'],
          )!,
      endTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}end_time'],
          )!,
    );
  }

  @override
  $LocalSchedulesTable createAlias(String alias) {
    return $LocalSchedulesTable(attachedDatabase, alias);
  }
}

class LocalSchedule extends DataClass implements Insertable<LocalSchedule> {
  final String id;
  final String institutionId;
  final String subjectId;
  final String groupId;
  final String teacherId;
  final String? roomId;
  final DateTime? date;
  final int weekday;
  final String startTime;
  final String endTime;
  const LocalSchedule({
    required this.id,
    required this.institutionId,
    required this.subjectId,
    required this.groupId,
    required this.teacherId,
    this.roomId,
    this.date,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['institution_id'] = Variable<String>(institutionId);
    map['subject_id'] = Variable<String>(subjectId);
    map['group_id'] = Variable<String>(groupId);
    map['teacher_id'] = Variable<String>(teacherId);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['weekday'] = Variable<int>(weekday);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    return map;
  }

  LocalSchedulesCompanion toCompanion(bool nullToAbsent) {
    return LocalSchedulesCompanion(
      id: Value(id),
      institutionId: Value(institutionId),
      subjectId: Value(subjectId),
      groupId: Value(groupId),
      teacherId: Value(teacherId),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      weekday: Value(weekday),
      startTime: Value(startTime),
      endTime: Value(endTime),
    );
  }

  factory LocalSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSchedule(
      id: serializer.fromJson<String>(json['id']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      teacherId: serializer.fromJson<String>(json['teacherId']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      date: serializer.fromJson<DateTime?>(json['date']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'institutionId': serializer.toJson<String>(institutionId),
      'subjectId': serializer.toJson<String>(subjectId),
      'groupId': serializer.toJson<String>(groupId),
      'teacherId': serializer.toJson<String>(teacherId),
      'roomId': serializer.toJson<String?>(roomId),
      'date': serializer.toJson<DateTime?>(date),
      'weekday': serializer.toJson<int>(weekday),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
    };
  }

  LocalSchedule copyWith({
    String? id,
    String? institutionId,
    String? subjectId,
    String? groupId,
    String? teacherId,
    Value<String?> roomId = const Value.absent(),
    Value<DateTime?> date = const Value.absent(),
    int? weekday,
    String? startTime,
    String? endTime,
  }) => LocalSchedule(
    id: id ?? this.id,
    institutionId: institutionId ?? this.institutionId,
    subjectId: subjectId ?? this.subjectId,
    groupId: groupId ?? this.groupId,
    teacherId: teacherId ?? this.teacherId,
    roomId: roomId.present ? roomId.value : this.roomId,
    date: date.present ? date.value : this.date,
    weekday: weekday ?? this.weekday,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
  );
  LocalSchedule copyWithCompanion(LocalSchedulesCompanion data) {
    return LocalSchedule(
      id: data.id.present ? data.id.value : this.id,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      date: data.date.present ? data.date.value : this.date,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSchedule(')
          ..write('id: $id, ')
          ..write('institutionId: $institutionId, ')
          ..write('subjectId: $subjectId, ')
          ..write('groupId: $groupId, ')
          ..write('teacherId: $teacherId, ')
          ..write('roomId: $roomId, ')
          ..write('date: $date, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    institutionId,
    subjectId,
    groupId,
    teacherId,
    roomId,
    date,
    weekday,
    startTime,
    endTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSchedule &&
          other.id == this.id &&
          other.institutionId == this.institutionId &&
          other.subjectId == this.subjectId &&
          other.groupId == this.groupId &&
          other.teacherId == this.teacherId &&
          other.roomId == this.roomId &&
          other.date == this.date &&
          other.weekday == this.weekday &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class LocalSchedulesCompanion extends UpdateCompanion<LocalSchedule> {
  final Value<String> id;
  final Value<String> institutionId;
  final Value<String> subjectId;
  final Value<String> groupId;
  final Value<String> teacherId;
  final Value<String?> roomId;
  final Value<DateTime?> date;
  final Value<int> weekday;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<int> rowid;
  const LocalSchedulesCompanion({
    this.id = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.date = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSchedulesCompanion.insert({
    required String id,
    required String institutionId,
    required String subjectId,
    required String groupId,
    required String teacherId,
    this.roomId = const Value.absent(),
    this.date = const Value.absent(),
    required int weekday,
    required String startTime,
    required String endTime,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       institutionId = Value(institutionId),
       subjectId = Value(subjectId),
       groupId = Value(groupId),
       teacherId = Value(teacherId),
       weekday = Value(weekday),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<LocalSchedule> custom({
    Expression<String>? id,
    Expression<String>? institutionId,
    Expression<String>? subjectId,
    Expression<String>? groupId,
    Expression<String>? teacherId,
    Expression<String>? roomId,
    Expression<DateTime>? date,
    Expression<int>? weekday,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (institutionId != null) 'institution_id': institutionId,
      if (subjectId != null) 'subject_id': subjectId,
      if (groupId != null) 'group_id': groupId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (roomId != null) 'room_id': roomId,
      if (date != null) 'date': date,
      if (weekday != null) 'weekday': weekday,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? institutionId,
    Value<String>? subjectId,
    Value<String>? groupId,
    Value<String>? teacherId,
    Value<String?>? roomId,
    Value<DateTime?>? date,
    Value<int>? weekday,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<int>? rowid,
  }) {
    return LocalSchedulesCompanion(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      subjectId: subjectId ?? this.subjectId,
      groupId: groupId ?? this.groupId,
      teacherId: teacherId ?? this.teacherId,
      roomId: roomId ?? this.roomId,
      date: date ?? this.date,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('institutionId: $institutionId, ')
          ..write('subjectId: $subjectId, ')
          ..write('groupId: $groupId, ')
          ..write('teacherId: $teacherId, ')
          ..write('roomId: $roomId, ')
          ..write('date: $date, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institutionNameMeta = const VerificationMeta(
    'institutionName',
  );
  @override
  late final GeneratedColumn<String> institutionName = GeneratedColumn<String>(
    'institution_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    name,
    surname,
    email,
    login,
    institutionId,
    groupId,
    avatarUrl,
    institutionName,
    groupName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('institution_name')) {
      context.handle(
        _institutionNameMeta,
        institutionName.isAcceptableOrUnknown(
          data['institution_name']!,
          _institutionNameMeta,
        ),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      surname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surname'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      login: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login'],
      ),
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      institutionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_name'],
      ),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String role;
  final String? name;
  final String? surname;
  final String? email;
  final String? login;
  final String institutionId;
  final String? groupId;
  final String? avatarUrl;
  final String? institutionName;
  final String? groupName;
  const LocalUser({
    required this.id,
    required this.role,
    this.name,
    this.surname,
    this.email,
    this.login,
    required this.institutionId,
    this.groupId,
    this.avatarUrl,
    this.institutionName,
    this.groupName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || surname != null) {
      map['surname'] = Variable<String>(surname);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || login != null) {
      map['login'] = Variable<String>(login);
    }
    map['institution_id'] = Variable<String>(institutionId);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || institutionName != null) {
      map['institution_name'] = Variable<String>(institutionName);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      role: Value(role),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      surname:
          surname == null && nullToAbsent
              ? const Value.absent()
              : Value(surname),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      login:
          login == null && nullToAbsent ? const Value.absent() : Value(login),
      institutionId: Value(institutionId),
      groupId:
          groupId == null && nullToAbsent
              ? const Value.absent()
              : Value(groupId),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
      institutionName:
          institutionName == null && nullToAbsent
              ? const Value.absent()
              : Value(institutionName),
      groupName:
          groupName == null && nullToAbsent
              ? const Value.absent()
              : Value(groupName),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      name: serializer.fromJson<String?>(json['name']),
      surname: serializer.fromJson<String?>(json['surname']),
      email: serializer.fromJson<String?>(json['email']),
      login: serializer.fromJson<String?>(json['login']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      institutionName: serializer.fromJson<String?>(json['institutionName']),
      groupName: serializer.fromJson<String?>(json['groupName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'name': serializer.toJson<String?>(name),
      'surname': serializer.toJson<String?>(surname),
      'email': serializer.toJson<String?>(email),
      'login': serializer.toJson<String?>(login),
      'institutionId': serializer.toJson<String>(institutionId),
      'groupId': serializer.toJson<String?>(groupId),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'institutionName': serializer.toJson<String?>(institutionName),
      'groupName': serializer.toJson<String?>(groupName),
    };
  }

  LocalUser copyWith({
    String? id,
    String? role,
    Value<String?> name = const Value.absent(),
    Value<String?> surname = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> login = const Value.absent(),
    String? institutionId,
    Value<String?> groupId = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> institutionName = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
  }) => LocalUser(
    id: id ?? this.id,
    role: role ?? this.role,
    name: name.present ? name.value : this.name,
    surname: surname.present ? surname.value : this.surname,
    email: email.present ? email.value : this.email,
    login: login.present ? login.value : this.login,
    institutionId: institutionId ?? this.institutionId,
    groupId: groupId.present ? groupId.value : this.groupId,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    institutionName:
        institutionName.present ? institutionName.value : this.institutionName,
    groupName: groupName.present ? groupName.value : this.groupName,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
      email: data.email.present ? data.email.value : this.email,
      login: data.login.present ? data.login.value : this.login,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      institutionName:
          data.institutionName.present
              ? data.institutionName.value
              : this.institutionName,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('institutionId: $institutionId, ')
          ..write('groupId: $groupId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('institutionName: $institutionName, ')
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    name,
    surname,
    email,
    login,
    institutionId,
    groupId,
    avatarUrl,
    institutionName,
    groupName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.role == this.role &&
          other.name == this.name &&
          other.surname == this.surname &&
          other.email == this.email &&
          other.login == this.login &&
          other.institutionId == this.institutionId &&
          other.groupId == this.groupId &&
          other.avatarUrl == this.avatarUrl &&
          other.institutionName == this.institutionName &&
          other.groupName == this.groupName);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> role;
  final Value<String?> name;
  final Value<String?> surname;
  final Value<String?> email;
  final Value<String?> login;
  final Value<String> institutionId;
  final Value<String?> groupId;
  final Value<String?> avatarUrl;
  final Value<String?> institutionName;
  final Value<String?> groupName;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.email = const Value.absent(),
    this.login = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    required String role,
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.email = const Value.absent(),
    this.login = const Value.absent(),
    required String institutionId,
    this.groupId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       institutionId = Value(institutionId);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<String>? email,
    Expression<String>? login,
    Expression<String>? institutionId,
    Expression<String>? groupId,
    Expression<String>? avatarUrl,
    Expression<String>? institutionName,
    Expression<String>? groupName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (email != null) 'email': email,
      if (login != null) 'login': login,
      if (institutionId != null) 'institution_id': institutionId,
      if (groupId != null) 'group_id': groupId,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (institutionName != null) 'institution_name': institutionName,
      if (groupName != null) 'group_name': groupName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String?>? name,
    Value<String?>? surname,
    Value<String?>? email,
    Value<String?>? login,
    Value<String>? institutionId,
    Value<String?>? groupId,
    Value<String?>? avatarUrl,
    Value<String?>? institutionName,
    Value<String?>? groupName,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      login: login ?? this.login,
      institutionId: institutionId ?? this.institutionId,
      groupId: groupId ?? this.groupId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      institutionName: institutionName ?? this.institutionName,
      groupName: groupName ?? this.groupName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (institutionName.present) {
      map['institution_name'] = Variable<String>(institutionName.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('institutionId: $institutionId, ')
          ..write('groupId: $groupId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('institutionName: $institutionName, ')
          ..write('groupName: $groupName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGradesTable extends LocalGrades
    with TableInfo<$LocalGradesTable, LocalGrade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lessonId, studentId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_grades';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGrade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGrade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGrade(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      lessonId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}lesson_id'],
          )!,
      studentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}student_id'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $LocalGradesTable createAlias(String alias) {
    return $LocalGradesTable(attachedDatabase, alias);
  }
}

class LocalGrade extends DataClass implements Insertable<LocalGrade> {
  final String id;
  final String lessonId;
  final String studentId;
  final int value;
  const LocalGrade({
    required this.id,
    required this.lessonId,
    required this.studentId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['student_id'] = Variable<String>(studentId);
    map['value'] = Variable<int>(value);
    return map;
  }

  LocalGradesCompanion toCompanion(bool nullToAbsent) {
    return LocalGradesCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      studentId: Value(studentId),
      value: Value(value),
    );
  }

  factory LocalGrade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGrade(
      id: serializer.fromJson<String>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'studentId': serializer.toJson<String>(studentId),
      'value': serializer.toJson<int>(value),
    };
  }

  LocalGrade copyWith({
    String? id,
    String? lessonId,
    String? studentId,
    int? value,
  }) => LocalGrade(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    studentId: studentId ?? this.studentId,
    value: value ?? this.value,
  );
  LocalGrade copyWithCompanion(LocalGradesCompanion data) {
    return LocalGrade(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGrade(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('studentId: $studentId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lessonId, studentId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGrade &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.studentId == this.studentId &&
          other.value == this.value);
}

class LocalGradesCompanion extends UpdateCompanion<LocalGrade> {
  final Value<String> id;
  final Value<String> lessonId;
  final Value<String> studentId;
  final Value<int> value;
  final Value<int> rowid;
  const LocalGradesCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGradesCompanion.insert({
    required String id,
    required String lessonId,
    required String studentId,
    required int value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lessonId = Value(lessonId),
       studentId = Value(studentId),
       value = Value(value);
  static Insertable<LocalGrade> custom({
    Expression<String>? id,
    Expression<String>? lessonId,
    Expression<String>? studentId,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (studentId != null) 'student_id': studentId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGradesCompanion copyWith({
    Value<String>? id,
    Value<String>? lessonId,
    Value<String>? studentId,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return LocalGradesCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      studentId: studentId ?? this.studentId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGradesCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('studentId: $studentId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHomeworksTable extends LocalHomeworks
    with TableInfo<$LocalHomeworksTable, LocalHomework> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHomeworksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileUrlMeta = const VerificationMeta(
    'fileUrl',
  );
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
    'file_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    groupId,
    lessonId,
    title,
    description,
    dueDate,
    createdAt,
    fileUrl,
    fileName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_homeworks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHomework> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('file_url')) {
      context.handle(
        _fileUrlMeta,
        fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHomework map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHomework(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      subjectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}subject_id'],
          )!,
      groupId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}group_id'],
          )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      ),
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      fileUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_url'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
    );
  }

  @override
  $LocalHomeworksTable createAlias(String alias) {
    return $LocalHomeworksTable(attachedDatabase, alias);
  }
}

class LocalHomework extends DataClass implements Insertable<LocalHomework> {
  final String id;
  final String subjectId;
  final String groupId;
  final String? lessonId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final String? fileUrl;
  final String? fileName;
  const LocalHomework({
    required this.id,
    required this.subjectId,
    required this.groupId,
    this.lessonId,
    required this.title,
    this.description,
    this.dueDate,
    this.createdAt,
    this.fileUrl,
    this.fileName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['group_id'] = Variable<String>(groupId);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<String>(lessonId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || fileUrl != null) {
      map['file_url'] = Variable<String>(fileUrl);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    return map;
  }

  LocalHomeworksCompanion toCompanion(bool nullToAbsent) {
    return LocalHomeworksCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      groupId: Value(groupId),
      lessonId:
          lessonId == null && nullToAbsent
              ? const Value.absent()
              : Value(lessonId),
      title: Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      dueDate:
          dueDate == null && nullToAbsent
              ? const Value.absent()
              : Value(dueDate),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      fileUrl:
          fileUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(fileUrl),
      fileName:
          fileName == null && nullToAbsent
              ? const Value.absent()
              : Value(fileName),
    );
  }

  factory LocalHomework.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHomework(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      lessonId: serializer.fromJson<String?>(json['lessonId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      fileUrl: serializer.fromJson<String?>(json['fileUrl']),
      fileName: serializer.fromJson<String?>(json['fileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'groupId': serializer.toJson<String>(groupId),
      'lessonId': serializer.toJson<String?>(lessonId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'fileUrl': serializer.toJson<String?>(fileUrl),
      'fileName': serializer.toJson<String?>(fileName),
    };
  }

  LocalHomework copyWith({
    String? id,
    String? subjectId,
    String? groupId,
    Value<String?> lessonId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<String?> fileUrl = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
  }) => LocalHomework(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    groupId: groupId ?? this.groupId,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    fileUrl: fileUrl.present ? fileUrl.value : this.fileUrl,
    fileName: fileName.present ? fileName.value : this.fileName,
  );
  LocalHomework copyWithCompanion(LocalHomeworksCompanion data) {
    return LocalHomework(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHomework(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('groupId: $groupId, ')
          ..write('lessonId: $lessonId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    groupId,
    lessonId,
    title,
    description,
    dueDate,
    createdAt,
    fileUrl,
    fileName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHomework &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.groupId == this.groupId &&
          other.lessonId == this.lessonId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.fileUrl == this.fileUrl &&
          other.fileName == this.fileName);
}

class LocalHomeworksCompanion extends UpdateCompanion<LocalHomework> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> groupId;
  final Value<String?> lessonId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> createdAt;
  final Value<String?> fileUrl;
  final Value<String?> fileName;
  final Value<int> rowid;
  const LocalHomeworksCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHomeworksCompanion.insert({
    required String id,
    required String subjectId,
    required String groupId,
    this.lessonId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       groupId = Value(groupId),
       title = Value(title);
  static Insertable<LocalHomework> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? groupId,
    Expression<String>? lessonId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<String>? fileUrl,
    Expression<String>? fileName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (groupId != null) 'group_id': groupId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileName != null) 'file_name': fileName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHomeworksCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<String>? groupId,
    Value<String?>? lessonId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? createdAt,
    Value<String?>? fileUrl,
    Value<String?>? fileName,
    Value<int>? rowid,
  }) {
    return LocalHomeworksCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      groupId: groupId ?? this.groupId,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHomeworksCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('groupId: $groupId, ')
          ..write('lessonId: $lessonId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHomeworkStatusesTable extends LocalHomeworkStatuses
    with TableInfo<$LocalHomeworkStatusesTable, LocalHomeworkStatuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHomeworkStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeworkIdMeta = const VerificationMeta(
    'homeworkId',
  );
  @override
  late final GeneratedColumn<String> homeworkId = GeneratedColumn<String>(
    'homework_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _studentCommentMeta = const VerificationMeta(
    'studentComment',
  );
  @override
  late final GeneratedColumn<String> studentComment = GeneratedColumn<String>(
    'student_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teacherCommentMeta = const VerificationMeta(
    'teacherComment',
  );
  @override
  late final GeneratedColumn<String> teacherComment = GeneratedColumn<String>(
    'teacher_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileUrlMeta = const VerificationMeta(
    'fileUrl',
  );
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
    'file_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    homeworkId,
    studentId,
    isCompleted,
    studentComment,
    teacherComment,
    fileUrl,
    fileName,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_homework_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHomeworkStatuse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('homework_id')) {
      context.handle(
        _homeworkIdMeta,
        homeworkId.isAcceptableOrUnknown(data['homework_id']!, _homeworkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeworkIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCompletedMeta);
    }
    if (data.containsKey('student_comment')) {
      context.handle(
        _studentCommentMeta,
        studentComment.isAcceptableOrUnknown(
          data['student_comment']!,
          _studentCommentMeta,
        ),
      );
    }
    if (data.containsKey('teacher_comment')) {
      context.handle(
        _teacherCommentMeta,
        teacherComment.isAcceptableOrUnknown(
          data['teacher_comment']!,
          _teacherCommentMeta,
        ),
      );
    }
    if (data.containsKey('file_url')) {
      context.handle(
        _fileUrlMeta,
        fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHomeworkStatuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHomeworkStatuse(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      homeworkId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}homework_id'],
          )!,
      studentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}student_id'],
          )!,
      isCompleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_completed'],
          )!,
      studentComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_comment'],
      ),
      teacherComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_comment'],
      ),
      fileUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_url'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $LocalHomeworkStatusesTable createAlias(String alias) {
    return $LocalHomeworkStatusesTable(attachedDatabase, alias);
  }
}

class LocalHomeworkStatuse extends DataClass
    implements Insertable<LocalHomeworkStatuse> {
  final String id;
  final String homeworkId;
  final String studentId;
  final bool isCompleted;
  final String? studentComment;
  final String? teacherComment;
  final String? fileUrl;
  final String? fileName;
  final DateTime updatedAt;
  const LocalHomeworkStatuse({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.isCompleted,
    this.studentComment,
    this.teacherComment,
    this.fileUrl,
    this.fileName,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['homework_id'] = Variable<String>(homeworkId);
    map['student_id'] = Variable<String>(studentId);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || studentComment != null) {
      map['student_comment'] = Variable<String>(studentComment);
    }
    if (!nullToAbsent || teacherComment != null) {
      map['teacher_comment'] = Variable<String>(teacherComment);
    }
    if (!nullToAbsent || fileUrl != null) {
      map['file_url'] = Variable<String>(fileUrl);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalHomeworkStatusesCompanion toCompanion(bool nullToAbsent) {
    return LocalHomeworkStatusesCompanion(
      id: Value(id),
      homeworkId: Value(homeworkId),
      studentId: Value(studentId),
      isCompleted: Value(isCompleted),
      studentComment:
          studentComment == null && nullToAbsent
              ? const Value.absent()
              : Value(studentComment),
      teacherComment:
          teacherComment == null && nullToAbsent
              ? const Value.absent()
              : Value(teacherComment),
      fileUrl:
          fileUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(fileUrl),
      fileName:
          fileName == null && nullToAbsent
              ? const Value.absent()
              : Value(fileName),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalHomeworkStatuse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHomeworkStatuse(
      id: serializer.fromJson<String>(json['id']),
      homeworkId: serializer.fromJson<String>(json['homeworkId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      studentComment: serializer.fromJson<String?>(json['studentComment']),
      teacherComment: serializer.fromJson<String?>(json['teacherComment']),
      fileUrl: serializer.fromJson<String?>(json['fileUrl']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'homeworkId': serializer.toJson<String>(homeworkId),
      'studentId': serializer.toJson<String>(studentId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'studentComment': serializer.toJson<String?>(studentComment),
      'teacherComment': serializer.toJson<String?>(teacherComment),
      'fileUrl': serializer.toJson<String?>(fileUrl),
      'fileName': serializer.toJson<String?>(fileName),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalHomeworkStatuse copyWith({
    String? id,
    String? homeworkId,
    String? studentId,
    bool? isCompleted,
    Value<String?> studentComment = const Value.absent(),
    Value<String?> teacherComment = const Value.absent(),
    Value<String?> fileUrl = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalHomeworkStatuse(
    id: id ?? this.id,
    homeworkId: homeworkId ?? this.homeworkId,
    studentId: studentId ?? this.studentId,
    isCompleted: isCompleted ?? this.isCompleted,
    studentComment:
        studentComment.present ? studentComment.value : this.studentComment,
    teacherComment:
        teacherComment.present ? teacherComment.value : this.teacherComment,
    fileUrl: fileUrl.present ? fileUrl.value : this.fileUrl,
    fileName: fileName.present ? fileName.value : this.fileName,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalHomeworkStatuse copyWithCompanion(LocalHomeworkStatusesCompanion data) {
    return LocalHomeworkStatuse(
      id: data.id.present ? data.id.value : this.id,
      homeworkId:
          data.homeworkId.present ? data.homeworkId.value : this.homeworkId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      studentComment:
          data.studentComment.present
              ? data.studentComment.value
              : this.studentComment,
      teacherComment:
          data.teacherComment.present
              ? data.teacherComment.value
              : this.teacherComment,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHomeworkStatuse(')
          ..write('id: $id, ')
          ..write('homeworkId: $homeworkId, ')
          ..write('studentId: $studentId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('studentComment: $studentComment, ')
          ..write('teacherComment: $teacherComment, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    homeworkId,
    studentId,
    isCompleted,
    studentComment,
    teacherComment,
    fileUrl,
    fileName,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHomeworkStatuse &&
          other.id == this.id &&
          other.homeworkId == this.homeworkId &&
          other.studentId == this.studentId &&
          other.isCompleted == this.isCompleted &&
          other.studentComment == this.studentComment &&
          other.teacherComment == this.teacherComment &&
          other.fileUrl == this.fileUrl &&
          other.fileName == this.fileName &&
          other.updatedAt == this.updatedAt);
}

class LocalHomeworkStatusesCompanion
    extends UpdateCompanion<LocalHomeworkStatuse> {
  final Value<String> id;
  final Value<String> homeworkId;
  final Value<String> studentId;
  final Value<bool> isCompleted;
  final Value<String?> studentComment;
  final Value<String?> teacherComment;
  final Value<String?> fileUrl;
  final Value<String?> fileName;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalHomeworkStatusesCompanion({
    this.id = const Value.absent(),
    this.homeworkId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.studentComment = const Value.absent(),
    this.teacherComment = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHomeworkStatusesCompanion.insert({
    required String id,
    required String homeworkId,
    required String studentId,
    required bool isCompleted,
    this.studentComment = const Value.absent(),
    this.teacherComment = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeworkId = Value(homeworkId),
       studentId = Value(studentId),
       isCompleted = Value(isCompleted),
       updatedAt = Value(updatedAt);
  static Insertable<LocalHomeworkStatuse> custom({
    Expression<String>? id,
    Expression<String>? homeworkId,
    Expression<String>? studentId,
    Expression<bool>? isCompleted,
    Expression<String>? studentComment,
    Expression<String>? teacherComment,
    Expression<String>? fileUrl,
    Expression<String>? fileName,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (homeworkId != null) 'homework_id': homeworkId,
      if (studentId != null) 'student_id': studentId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (studentComment != null) 'student_comment': studentComment,
      if (teacherComment != null) 'teacher_comment': teacherComment,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileName != null) 'file_name': fileName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHomeworkStatusesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeworkId,
    Value<String>? studentId,
    Value<bool>? isCompleted,
    Value<String?>? studentComment,
    Value<String?>? teacherComment,
    Value<String?>? fileUrl,
    Value<String?>? fileName,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalHomeworkStatusesCompanion(
      id: id ?? this.id,
      homeworkId: homeworkId ?? this.homeworkId,
      studentId: studentId ?? this.studentId,
      isCompleted: isCompleted ?? this.isCompleted,
      studentComment: studentComment ?? this.studentComment,
      teacherComment: teacherComment ?? this.teacherComment,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (homeworkId.present) {
      map['homework_id'] = Variable<String>(homeworkId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (studentComment.present) {
      map['student_comment'] = Variable<String>(studentComment.value);
    }
    if (teacherComment.present) {
      map['teacher_comment'] = Variable<String>(teacherComment.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHomeworkStatusesCompanion(')
          ..write('id: $id, ')
          ..write('homeworkId: $homeworkId, ')
          ..write('studentId: $studentId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('studentComment: $studentComment, ')
          ..write('teacherComment: $teacherComment, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStudentsTable extends LocalStudents
    with TableInfo<$LocalStudentsTable, LocalStudent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHeadmanMeta = const VerificationMeta(
    'isHeadman',
  );
  @override
  late final GeneratedColumn<bool> isHeadman = GeneratedColumn<bool>(
    'is_headman',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_headman" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    surname,
    email,
    login,
    groupId,
    isHeadman,
    createdAt,
    avatarUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStudent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    } else if (isInserting) {
      context.missing(_loginMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('is_headman')) {
      context.handle(
        _isHeadmanMeta,
        isHeadman.isAcceptableOrUnknown(data['is_headman']!, _isHeadmanMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStudent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudent(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      surname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}surname'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      login:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}login'],
          )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      isHeadman:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_headman'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
    );
  }

  @override
  $LocalStudentsTable createAlias(String alias) {
    return $LocalStudentsTable(attachedDatabase, alias);
  }
}

class LocalStudent extends DataClass implements Insertable<LocalStudent> {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String? groupId;
  final bool isHeadman;
  final DateTime createdAt;
  final String? avatarUrl;
  const LocalStudent({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    this.groupId,
    required this.isHeadman,
    required this.createdAt,
    this.avatarUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['surname'] = Variable<String>(surname);
    map['email'] = Variable<String>(email);
    map['login'] = Variable<String>(login);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['is_headman'] = Variable<bool>(isHeadman);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    return map;
  }

  LocalStudentsCompanion toCompanion(bool nullToAbsent) {
    return LocalStudentsCompanion(
      id: Value(id),
      name: Value(name),
      surname: Value(surname),
      email: Value(email),
      login: Value(login),
      groupId:
          groupId == null && nullToAbsent
              ? const Value.absent()
              : Value(groupId),
      isHeadman: Value(isHeadman),
      createdAt: Value(createdAt),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
    );
  }

  factory LocalStudent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudent(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      surname: serializer.fromJson<String>(json['surname']),
      email: serializer.fromJson<String>(json['email']),
      login: serializer.fromJson<String>(json['login']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      isHeadman: serializer.fromJson<bool>(json['isHeadman']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'surname': serializer.toJson<String>(surname),
      'email': serializer.toJson<String>(email),
      'login': serializer.toJson<String>(login),
      'groupId': serializer.toJson<String?>(groupId),
      'isHeadman': serializer.toJson<bool>(isHeadman),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
    };
  }

  LocalStudent copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? login,
    Value<String?> groupId = const Value.absent(),
    bool? isHeadman,
    DateTime? createdAt,
    Value<String?> avatarUrl = const Value.absent(),
  }) => LocalStudent(
    id: id ?? this.id,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    email: email ?? this.email,
    login: login ?? this.login,
    groupId: groupId.present ? groupId.value : this.groupId,
    isHeadman: isHeadman ?? this.isHeadman,
    createdAt: createdAt ?? this.createdAt,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
  );
  LocalStudent copyWithCompanion(LocalStudentsCompanion data) {
    return LocalStudent(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
      email: data.email.present ? data.email.value : this.email,
      login: data.login.present ? data.login.value : this.login,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      isHeadman: data.isHeadman.present ? data.isHeadman.value : this.isHeadman,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudent(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('groupId: $groupId, ')
          ..write('isHeadman: $isHeadman, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    surname,
    email,
    login,
    groupId,
    isHeadman,
    createdAt,
    avatarUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudent &&
          other.id == this.id &&
          other.name == this.name &&
          other.surname == this.surname &&
          other.email == this.email &&
          other.login == this.login &&
          other.groupId == this.groupId &&
          other.isHeadman == this.isHeadman &&
          other.createdAt == this.createdAt &&
          other.avatarUrl == this.avatarUrl);
}

class LocalStudentsCompanion extends UpdateCompanion<LocalStudent> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> surname;
  final Value<String> email;
  final Value<String> login;
  final Value<String?> groupId;
  final Value<bool> isHeadman;
  final Value<DateTime> createdAt;
  final Value<String?> avatarUrl;
  final Value<int> rowid;
  const LocalStudentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.email = const Value.absent(),
    this.login = const Value.absent(),
    this.groupId = const Value.absent(),
    this.isHeadman = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudentsCompanion.insert({
    required String id,
    required String name,
    required String surname,
    required String email,
    required String login,
    this.groupId = const Value.absent(),
    this.isHeadman = const Value.absent(),
    required DateTime createdAt,
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       surname = Value(surname),
       email = Value(email),
       login = Value(login),
       createdAt = Value(createdAt);
  static Insertable<LocalStudent> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<String>? email,
    Expression<String>? login,
    Expression<String>? groupId,
    Expression<bool>? isHeadman,
    Expression<DateTime>? createdAt,
    Expression<String>? avatarUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (email != null) 'email': email,
      if (login != null) 'login': login,
      if (groupId != null) 'group_id': groupId,
      if (isHeadman != null) 'is_headman': isHeadman,
      if (createdAt != null) 'created_at': createdAt,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? surname,
    Value<String>? email,
    Value<String>? login,
    Value<String?>? groupId,
    Value<bool>? isHeadman,
    Value<DateTime>? createdAt,
    Value<String?>? avatarUrl,
    Value<int>? rowid,
  }) {
    return LocalStudentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      login: login ?? this.login,
      groupId: groupId ?? this.groupId,
      isHeadman: isHeadman ?? this.isHeadman,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (isHeadman.present) {
      map['is_headman'] = Variable<bool>(isHeadman.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('groupId: $groupId, ')
          ..write('isHeadman: $isHeadman, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGroupDetailsTable extends LocalGroupDetails
    with TableInfo<$LocalGroupDetailsTable, LocalGroupDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGroupDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _curatorIdMeta = const VerificationMeta(
    'curatorId',
  );
  @override
  late final GeneratedColumn<String> curatorId = GeneratedColumn<String>(
    'curator_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    institutionId,
    curatorId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_group_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGroupDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('curator_id')) {
      context.handle(
        _curatorIdMeta,
        curatorId.isAcceptableOrUnknown(data['curator_id']!, _curatorIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGroupDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGroupDetail(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
      curatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}curator_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $LocalGroupDetailsTable createAlias(String alias) {
    return $LocalGroupDetailsTable(attachedDatabase, alias);
  }
}

class LocalGroupDetail extends DataClass
    implements Insertable<LocalGroupDetail> {
  final String id;
  final String name;
  final String institutionId;
  final String? curatorId;
  final DateTime? createdAt;
  const LocalGroupDetail({
    required this.id,
    required this.name,
    required this.institutionId,
    this.curatorId,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['institution_id'] = Variable<String>(institutionId);
    if (!nullToAbsent || curatorId != null) {
      map['curator_id'] = Variable<String>(curatorId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  LocalGroupDetailsCompanion toCompanion(bool nullToAbsent) {
    return LocalGroupDetailsCompanion(
      id: Value(id),
      name: Value(name),
      institutionId: Value(institutionId),
      curatorId:
          curatorId == null && nullToAbsent
              ? const Value.absent()
              : Value(curatorId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
    );
  }

  factory LocalGroupDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGroupDetail(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      curatorId: serializer.fromJson<String?>(json['curatorId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'institutionId': serializer.toJson<String>(institutionId),
      'curatorId': serializer.toJson<String?>(curatorId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  LocalGroupDetail copyWith({
    String? id,
    String? name,
    String? institutionId,
    Value<String?> curatorId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => LocalGroupDetail(
    id: id ?? this.id,
    name: name ?? this.name,
    institutionId: institutionId ?? this.institutionId,
    curatorId: curatorId.present ? curatorId.value : this.curatorId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  LocalGroupDetail copyWithCompanion(LocalGroupDetailsCompanion data) {
    return LocalGroupDetail(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
      curatorId: data.curatorId.present ? data.curatorId.value : this.curatorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupDetail(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId, ')
          ..write('curatorId: $curatorId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, institutionId, curatorId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGroupDetail &&
          other.id == this.id &&
          other.name == this.name &&
          other.institutionId == this.institutionId &&
          other.curatorId == this.curatorId &&
          other.createdAt == this.createdAt);
}

class LocalGroupDetailsCompanion extends UpdateCompanion<LocalGroupDetail> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> institutionId;
  final Value<String?> curatorId;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const LocalGroupDetailsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.curatorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGroupDetailsCompanion.insert({
    required String id,
    required String name,
    required String institutionId,
    this.curatorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       institutionId = Value(institutionId);
  static Insertable<LocalGroupDetail> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? institutionId,
    Expression<String>? curatorId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (institutionId != null) 'institution_id': institutionId,
      if (curatorId != null) 'curator_id': curatorId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGroupDetailsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? institutionId,
    Value<String?>? curatorId,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalGroupDetailsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      institutionId: institutionId ?? this.institutionId,
      curatorId: curatorId ?? this.curatorId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (curatorId.present) {
      map['curator_id'] = Variable<String>(curatorId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupDetailsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institutionId: $institutionId, ')
          ..write('curatorId: $curatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTeacherProfilesTable extends LocalTeacherProfiles
    with TableInfo<$LocalTeacherProfilesTable, LocalTeacherProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTeacherProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    surname,
    email,
    login,
    institutionId,
    department,
    createdAt,
    avatarUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_teacher_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTeacherProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    } else if (isInserting) {
      context.missing(_loginMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTeacherProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTeacherProfile(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      surname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}surname'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      login:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}login'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
    );
  }

  @override
  $LocalTeacherProfilesTable createAlias(String alias) {
    return $LocalTeacherProfilesTable(attachedDatabase, alias);
  }
}

class LocalTeacherProfile extends DataClass
    implements Insertable<LocalTeacherProfile> {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String institutionId;
  final String? department;
  final DateTime createdAt;
  final String? avatarUrl;
  const LocalTeacherProfile({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.institutionId,
    this.department,
    required this.createdAt,
    this.avatarUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['surname'] = Variable<String>(surname);
    map['email'] = Variable<String>(email);
    map['login'] = Variable<String>(login);
    map['institution_id'] = Variable<String>(institutionId);
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    return map;
  }

  LocalTeacherProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalTeacherProfilesCompanion(
      id: Value(id),
      name: Value(name),
      surname: Value(surname),
      email: Value(email),
      login: Value(login),
      institutionId: Value(institutionId),
      department:
          department == null && nullToAbsent
              ? const Value.absent()
              : Value(department),
      createdAt: Value(createdAt),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
    );
  }

  factory LocalTeacherProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTeacherProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      surname: serializer.fromJson<String>(json['surname']),
      email: serializer.fromJson<String>(json['email']),
      login: serializer.fromJson<String>(json['login']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      department: serializer.fromJson<String?>(json['department']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'surname': serializer.toJson<String>(surname),
      'email': serializer.toJson<String>(email),
      'login': serializer.toJson<String>(login),
      'institutionId': serializer.toJson<String>(institutionId),
      'department': serializer.toJson<String?>(department),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
    };
  }

  LocalTeacherProfile copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? login,
    String? institutionId,
    Value<String?> department = const Value.absent(),
    DateTime? createdAt,
    Value<String?> avatarUrl = const Value.absent(),
  }) => LocalTeacherProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    email: email ?? this.email,
    login: login ?? this.login,
    institutionId: institutionId ?? this.institutionId,
    department: department.present ? department.value : this.department,
    createdAt: createdAt ?? this.createdAt,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
  );
  LocalTeacherProfile copyWithCompanion(LocalTeacherProfilesCompanion data) {
    return LocalTeacherProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
      email: data.email.present ? data.email.value : this.email,
      login: data.login.present ? data.login.value : this.login,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
      department:
          data.department.present ? data.department.value : this.department,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTeacherProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('institutionId: $institutionId, ')
          ..write('department: $department, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    surname,
    email,
    login,
    institutionId,
    department,
    createdAt,
    avatarUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTeacherProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.surname == this.surname &&
          other.email == this.email &&
          other.login == this.login &&
          other.institutionId == this.institutionId &&
          other.department == this.department &&
          other.createdAt == this.createdAt &&
          other.avatarUrl == this.avatarUrl);
}

class LocalTeacherProfilesCompanion
    extends UpdateCompanion<LocalTeacherProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> surname;
  final Value<String> email;
  final Value<String> login;
  final Value<String> institutionId;
  final Value<String?> department;
  final Value<DateTime> createdAt;
  final Value<String?> avatarUrl;
  final Value<int> rowid;
  const LocalTeacherProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.email = const Value.absent(),
    this.login = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.department = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTeacherProfilesCompanion.insert({
    required String id,
    required String name,
    required String surname,
    required String email,
    required String login,
    required String institutionId,
    this.department = const Value.absent(),
    required DateTime createdAt,
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       surname = Value(surname),
       email = Value(email),
       login = Value(login),
       institutionId = Value(institutionId),
       createdAt = Value(createdAt);
  static Insertable<LocalTeacherProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<String>? email,
    Expression<String>? login,
    Expression<String>? institutionId,
    Expression<String>? department,
    Expression<DateTime>? createdAt,
    Expression<String>? avatarUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (email != null) 'email': email,
      if (login != null) 'login': login,
      if (institutionId != null) 'institution_id': institutionId,
      if (department != null) 'department': department,
      if (createdAt != null) 'created_at': createdAt,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTeacherProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? surname,
    Value<String>? email,
    Value<String>? login,
    Value<String>? institutionId,
    Value<String?>? department,
    Value<DateTime>? createdAt,
    Value<String?>? avatarUrl,
    Value<int>? rowid,
  }) {
    return LocalTeacherProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      login: login ?? this.login,
      institutionId: institutionId ?? this.institutionId,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTeacherProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('institutionId: $institutionId, ')
          ..write('department: $department, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAdminProfilesTable extends LocalAdminProfiles
    with TableInfo<$LocalAdminProfilesTable, LocalAdminProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAdminProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    surname,
    email,
    login,
    institutionId,
    phone,
    createdAt,
    avatarUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_admin_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAdminProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    } else if (isInserting) {
      context.missing(_loginMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAdminProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAdminProfile(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      surname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}surname'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      login:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}login'],
          )!,
      institutionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}institution_id'],
          )!,
      phone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}phone'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
    );
  }

  @override
  $LocalAdminProfilesTable createAlias(String alias) {
    return $LocalAdminProfilesTable(attachedDatabase, alias);
  }
}

class LocalAdminProfile extends DataClass
    implements Insertable<LocalAdminProfile> {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String institutionId;
  final String phone;
  final DateTime createdAt;
  final String? avatarUrl;
  const LocalAdminProfile({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.institutionId,
    required this.phone,
    required this.createdAt,
    this.avatarUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['surname'] = Variable<String>(surname);
    map['email'] = Variable<String>(email);
    map['login'] = Variable<String>(login);
    map['institution_id'] = Variable<String>(institutionId);
    map['phone'] = Variable<String>(phone);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    return map;
  }

  LocalAdminProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalAdminProfilesCompanion(
      id: Value(id),
      name: Value(name),
      surname: Value(surname),
      email: Value(email),
      login: Value(login),
      institutionId: Value(institutionId),
      phone: Value(phone),
      createdAt: Value(createdAt),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
    );
  }

  factory LocalAdminProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAdminProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      surname: serializer.fromJson<String>(json['surname']),
      email: serializer.fromJson<String>(json['email']),
      login: serializer.fromJson<String>(json['login']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      phone: serializer.fromJson<String>(json['phone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'surname': serializer.toJson<String>(surname),
      'email': serializer.toJson<String>(email),
      'login': serializer.toJson<String>(login),
      'institutionId': serializer.toJson<String>(institutionId),
      'phone': serializer.toJson<String>(phone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
    };
  }

  LocalAdminProfile copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? login,
    String? institutionId,
    String? phone,
    DateTime? createdAt,
    Value<String?> avatarUrl = const Value.absent(),
  }) => LocalAdminProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    email: email ?? this.email,
    login: login ?? this.login,
    institutionId: institutionId ?? this.institutionId,
    phone: phone ?? this.phone,
    createdAt: createdAt ?? this.createdAt,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
  );
  LocalAdminProfile copyWithCompanion(LocalAdminProfilesCompanion data) {
    return LocalAdminProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
      email: data.email.present ? data.email.value : this.email,
      login: data.login.present ? data.login.value : this.login,
      institutionId:
          data.institutionId.present
              ? data.institutionId.value
              : this.institutionId,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAdminProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('institutionId: $institutionId, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    surname,
    email,
    login,
    institutionId,
    phone,
    createdAt,
    avatarUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAdminProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.surname == this.surname &&
          other.email == this.email &&
          other.login == this.login &&
          other.institutionId == this.institutionId &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt &&
          other.avatarUrl == this.avatarUrl);
}

class LocalAdminProfilesCompanion extends UpdateCompanion<LocalAdminProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> surname;
  final Value<String> email;
  final Value<String> login;
  final Value<String> institutionId;
  final Value<String> phone;
  final Value<DateTime> createdAt;
  final Value<String?> avatarUrl;
  final Value<int> rowid;
  const LocalAdminProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.email = const Value.absent(),
    this.login = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAdminProfilesCompanion.insert({
    required String id,
    required String name,
    required String surname,
    required String email,
    required String login,
    required String institutionId,
    required String phone,
    required DateTime createdAt,
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       surname = Value(surname),
       email = Value(email),
       login = Value(login),
       institutionId = Value(institutionId),
       phone = Value(phone),
       createdAt = Value(createdAt);
  static Insertable<LocalAdminProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<String>? email,
    Expression<String>? login,
    Expression<String>? institutionId,
    Expression<String>? phone,
    Expression<DateTime>? createdAt,
    Expression<String>? avatarUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (email != null) 'email': email,
      if (login != null) 'login': login,
      if (institutionId != null) 'institution_id': institutionId,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAdminProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? surname,
    Value<String>? email,
    Value<String>? login,
    Value<String>? institutionId,
    Value<String>? phone,
    Value<DateTime>? createdAt,
    Value<String?>? avatarUrl,
    Value<int>? rowid,
  }) {
    return LocalAdminProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      login: login ?? this.login,
      institutionId: institutionId ?? this.institutionId,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAdminProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('email: $email, ')
          ..write('login: $login, ')
          ..write('institutionId: $institutionId, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInstitutionsTable extends LocalInstitutions
    with TableInfo<$LocalInstitutionsTable, LocalInstitution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInstitutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, address, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_institutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInstitution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInstitution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInstitution(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      address:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}address'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $LocalInstitutionsTable createAlias(String alias) {
    return $LocalInstitutionsTable(attachedDatabase, alias);
  }
}

class LocalInstitution extends DataClass
    implements Insertable<LocalInstitution> {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;
  const LocalInstitution({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalInstitutionsCompanion toCompanion(bool nullToAbsent) {
    return LocalInstitutionsCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      createdAt: Value(createdAt),
    );
  }

  factory LocalInstitution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInstitution(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalInstitution copyWith({
    String? id,
    String? name,
    String? address,
    DateTime? createdAt,
  }) => LocalInstitution(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalInstitution copyWithCompanion(LocalInstitutionsCompanion data) {
    return LocalInstitution(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInstitution(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, address, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInstitution &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.createdAt == this.createdAt);
}

class LocalInstitutionsCompanion extends UpdateCompanion<LocalInstitution> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> address;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalInstitutionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInstitutionsCompanion.insert({
    required String id,
    required String name,
    required String address,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       address = Value(address),
       createdAt = Value(createdAt);
  static Insertable<LocalInstitution> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInstitutionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? address,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalInstitutionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLessonsTable extends LocalLessons
    with TableInfo<$LocalLessonsTable, LocalLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attendanceStatusMeta = const VerificationMeta(
    'attendanceStatus',
  );
  @override
  late final GeneratedColumn<String> attendanceStatus = GeneratedColumn<String>(
    'attendance_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduleId,
    topic,
    attendanceStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('attendance_status')) {
      context.handle(
        _attendanceStatusMeta,
        attendanceStatus.isAcceptableOrUnknown(
          data['attendance_status']!,
          _attendanceStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLesson(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      scheduleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}schedule_id'],
          )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      attendanceStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}attendance_status'],
          )!,
    );
  }

  @override
  $LocalLessonsTable createAlias(String alias) {
    return $LocalLessonsTable(attachedDatabase, alias);
  }
}

class LocalLesson extends DataClass implements Insertable<LocalLesson> {
  final String id;
  final String scheduleId;
  final String? topic;
  final String attendanceStatus;
  const LocalLesson({
    required this.id,
    required this.scheduleId,
    this.topic,
    required this.attendanceStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schedule_id'] = Variable<String>(scheduleId);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    map['attendance_status'] = Variable<String>(attendanceStatus);
    return map;
  }

  LocalLessonsCompanion toCompanion(bool nullToAbsent) {
    return LocalLessonsCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      attendanceStatus: Value(attendanceStatus),
    );
  }

  factory LocalLesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLesson(
      id: serializer.fromJson<String>(json['id']),
      scheduleId: serializer.fromJson<String>(json['scheduleId']),
      topic: serializer.fromJson<String?>(json['topic']),
      attendanceStatus: serializer.fromJson<String>(json['attendanceStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scheduleId': serializer.toJson<String>(scheduleId),
      'topic': serializer.toJson<String?>(topic),
      'attendanceStatus': serializer.toJson<String>(attendanceStatus),
    };
  }

  LocalLesson copyWith({
    String? id,
    String? scheduleId,
    Value<String?> topic = const Value.absent(),
    String? attendanceStatus,
  }) => LocalLesson(
    id: id ?? this.id,
    scheduleId: scheduleId ?? this.scheduleId,
    topic: topic.present ? topic.value : this.topic,
    attendanceStatus: attendanceStatus ?? this.attendanceStatus,
  );
  LocalLesson copyWithCompanion(LocalLessonsCompanion data) {
    return LocalLesson(
      id: data.id.present ? data.id.value : this.id,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      topic: data.topic.present ? data.topic.value : this.topic,
      attendanceStatus:
          data.attendanceStatus.present
              ? data.attendanceStatus.value
              : this.attendanceStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLesson(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('topic: $topic, ')
          ..write('attendanceStatus: $attendanceStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduleId, topic, attendanceStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLesson &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.topic == this.topic &&
          other.attendanceStatus == this.attendanceStatus);
}

class LocalLessonsCompanion extends UpdateCompanion<LocalLesson> {
  final Value<String> id;
  final Value<String> scheduleId;
  final Value<String?> topic;
  final Value<String> attendanceStatus;
  final Value<int> rowid;
  const LocalLessonsCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.topic = const Value.absent(),
    this.attendanceStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLessonsCompanion.insert({
    required String id,
    required String scheduleId,
    this.topic = const Value.absent(),
    this.attendanceStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduleId = Value(scheduleId);
  static Insertable<LocalLesson> custom({
    Expression<String>? id,
    Expression<String>? scheduleId,
    Expression<String>? topic,
    Expression<String>? attendanceStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (topic != null) 'topic': topic,
      if (attendanceStatus != null) 'attendance_status': attendanceStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLessonsCompanion copyWith({
    Value<String>? id,
    Value<String>? scheduleId,
    Value<String?>? topic,
    Value<String>? attendanceStatus,
    Value<int>? rowid,
  }) {
    return LocalLessonsCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      topic: topic ?? this.topic,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (attendanceStatus.present) {
      map['attendance_status'] = Variable<String>(attendanceStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLessonsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('topic: $topic, ')
          ..write('attendanceStatus: $attendanceStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLessonAttendancesTable extends LocalLessonAttendances
    with TableInfo<$LocalLessonAttendancesTable, LocalLessonAttendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLessonAttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lessonId, studentId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lesson_attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLessonAttendance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId, studentId};
  @override
  LocalLessonAttendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLessonAttendance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      lessonId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}lesson_id'],
          )!,
      studentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}student_id'],
          )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
    );
  }

  @override
  $LocalLessonAttendancesTable createAlias(String alias) {
    return $LocalLessonAttendancesTable(attachedDatabase, alias);
  }
}

class LocalLessonAttendance extends DataClass
    implements Insertable<LocalLessonAttendance> {
  final String? id;
  final String lessonId;
  final String studentId;
  final String? status;
  const LocalLessonAttendance({
    this.id,
    required this.lessonId,
    required this.studentId,
    this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['lesson_id'] = Variable<String>(lessonId);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    return map;
  }

  LocalLessonAttendancesCompanion toCompanion(bool nullToAbsent) {
    return LocalLessonAttendancesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      lessonId: Value(lessonId),
      studentId: Value(studentId),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
    );
  }

  factory LocalLessonAttendance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLessonAttendance(
      id: serializer.fromJson<String?>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      status: serializer.fromJson<String?>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String?>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'studentId': serializer.toJson<String>(studentId),
      'status': serializer.toJson<String?>(status),
    };
  }

  LocalLessonAttendance copyWith({
    Value<String?> id = const Value.absent(),
    String? lessonId,
    String? studentId,
    Value<String?> status = const Value.absent(),
  }) => LocalLessonAttendance(
    id: id.present ? id.value : this.id,
    lessonId: lessonId ?? this.lessonId,
    studentId: studentId ?? this.studentId,
    status: status.present ? status.value : this.status,
  );
  LocalLessonAttendance copyWithCompanion(
    LocalLessonAttendancesCompanion data,
  ) {
    return LocalLessonAttendance(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLessonAttendance(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lessonId, studentId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLessonAttendance &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.studentId == this.studentId &&
          other.status == this.status);
}

class LocalLessonAttendancesCompanion
    extends UpdateCompanion<LocalLessonAttendance> {
  final Value<String?> id;
  final Value<String> lessonId;
  final Value<String> studentId;
  final Value<String?> status;
  final Value<int> rowid;
  const LocalLessonAttendancesCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLessonAttendancesCompanion.insert({
    this.id = const Value.absent(),
    required String lessonId,
    required String studentId,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId),
       studentId = Value(studentId);
  static Insertable<LocalLessonAttendance> custom({
    Expression<String>? id,
    Expression<String>? lessonId,
    Expression<String>? studentId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (studentId != null) 'student_id': studentId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLessonAttendancesCompanion copyWith({
    Value<String?>? id,
    Value<String>? lessonId,
    Value<String>? studentId,
    Value<String?>? status,
    Value<int>? rowid,
  }) {
    return LocalLessonAttendancesCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLessonAttendancesCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalChatsTable extends LocalChats
    with TableInfo<$LocalChatsTable, LocalChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, name, groupId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChat(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $LocalChatsTable createAlias(String alias) {
    return $LocalChatsTable(attachedDatabase, alias);
  }
}

class LocalChat extends DataClass implements Insertable<LocalChat> {
  final String id;
  final String type;
  final String? name;
  final String? groupId;
  final DateTime updatedAt;
  const LocalChat({
    required this.id,
    required this.type,
    this.name,
    this.groupId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalChatsCompanion toCompanion(bool nullToAbsent) {
    return LocalChatsCompanion(
      id: Value(id),
      type: Value(type),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      groupId:
          groupId == null && nullToAbsent
              ? const Value.absent()
              : Value(groupId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChat(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String?>(json['name']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String?>(name),
      'groupId': serializer.toJson<String?>(groupId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalChat copyWith({
    String? id,
    String? type,
    Value<String?> name = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalChat(
    id: id ?? this.id,
    type: type ?? this.type,
    name: name.present ? name.value : this.name,
    groupId: groupId.present ? groupId.value : this.groupId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalChat copyWithCompanion(LocalChatsCompanion data) {
    return LocalChat(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChat(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, name, groupId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChat &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.groupId == this.groupId &&
          other.updatedAt == this.updatedAt);
}

class LocalChatsCompanion extends UpdateCompanion<LocalChat> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> name;
  final Value<String?> groupId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalChatsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChatsCompanion.insert({
    required String id,
    required String type,
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       updatedAt = Value(updatedAt);
  static Insertable<LocalChat> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? groupId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (groupId != null) 'group_id': groupId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? name,
    Value<String?>? groupId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalChatsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderRoleMeta = const VerificationMeta(
    'senderRole',
  );
  @override
  late final GeneratedColumn<String> senderRole = GeneratedColumn<String>(
    'sender_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileUrlMeta = const VerificationMeta(
    'fileUrl',
  );
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
    'file_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderId,
    senderRole,
    content,
    fileUrl,
    fileName,
    isRead,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_role')) {
      context.handle(
        _senderRoleMeta,
        senderRole.isAcceptableOrUnknown(data['sender_role']!, _senderRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_senderRoleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('file_url')) {
      context.handle(
        _fileUrlMeta,
        fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessage(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      senderId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_id'],
          )!,
      senderRole:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_role'],
          )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      fileUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_url'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      isRead:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_read'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessage extends DataClass implements Insertable<LocalMessage> {
  final String id;
  final String chatId;
  final String senderId;
  final String senderRole;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime createdAt;
  const LocalMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    this.content,
    this.fileUrl,
    this.fileName,
    required this.isRead,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_role'] = Variable<String>(senderRole);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || fileUrl != null) {
      map['file_url'] = Variable<String>(fileUrl);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      senderRole: Value(senderRole),
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      fileUrl:
          fileUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(fileUrl),
      fileName:
          fileName == null && nullToAbsent
              ? const Value.absent()
              : Value(fileName),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
    );
  }

  factory LocalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessage(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderRole: serializer.fromJson<String>(json['senderRole']),
      content: serializer.fromJson<String?>(json['content']),
      fileUrl: serializer.fromJson<String?>(json['fileUrl']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'senderRole': serializer.toJson<String>(senderRole),
      'content': serializer.toJson<String?>(content),
      'fileUrl': serializer.toJson<String?>(fileUrl),
      'fileName': serializer.toJson<String?>(fileName),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderRole,
    Value<String?> content = const Value.absent(),
    Value<String?> fileUrl = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
    bool? isRead,
    DateTime? createdAt,
  }) => LocalMessage(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    senderRole: senderRole ?? this.senderRole,
    content: content.present ? content.value : this.content,
    fileUrl: fileUrl.present ? fileUrl.value : this.fileUrl,
    fileName: fileName.present ? fileName.value : this.fileName,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalMessage copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessage(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderRole:
          data.senderRole.present ? data.senderRole.value : this.senderRole,
      content: data.content.present ? data.content.value : this.content,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessage(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('senderRole: $senderRole, ')
          ..write('content: $content, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderId,
    senderRole,
    content,
    fileUrl,
    fileName,
    isRead,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessage &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.senderRole == this.senderRole &&
          other.content == this.content &&
          other.fileUrl == this.fileUrl &&
          other.fileName == this.fileName &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessage> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> senderId;
  final Value<String> senderRole;
  final Value<String?> content;
  final Value<String?> fileUrl;
  final Value<String?> fileName;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalMessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderRole = const Value.absent(),
    this.content = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    required String id,
    required String chatId,
    required String senderId,
    required String senderRole,
    this.content = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       senderRole = Value(senderRole),
       createdAt = Value(createdAt);
  static Insertable<LocalMessage> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? senderId,
    Expression<String>? senderRole,
    Expression<String>? content,
    Expression<String>? fileUrl,
    Expression<String>? fileName,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (senderRole != null) 'sender_role': senderRole,
      if (content != null) 'content': content,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileName != null) 'file_name': fileName,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? senderId,
    Value<String>? senderRole,
    Value<String?>? content,
    Value<String?>? fileUrl,
    Value<String?>? fileName,
    Value<bool>? isRead,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalMessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderRole.present) {
      map['sender_role'] = Variable<String>(senderRole.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('senderRole: $senderRole, ')
          ..write('content: $content, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalChatPreviewsTable extends LocalChatPreviews
    with TableInfo<$LocalChatPreviewsTable, LocalChatPreview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatPreviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTimeMeta = const VerificationMeta(
    'lastMessageTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageTime =
      GeneratedColumn<DateTime>(
        'last_message_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chatTypeMeta = const VerificationMeta(
    'chatType',
  );
  @override
  late final GeneratedColumn<String> chatType = GeneratedColumn<String>(
    'chat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatNameMeta = const VerificationMeta(
    'chatName',
  );
  @override
  late final GeneratedColumn<String> chatName = GeneratedColumn<String>(
    'chat_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatGroupIdMeta = const VerificationMeta(
    'chatGroupId',
  );
  @override
  late final GeneratedColumn<String> chatGroupId = GeneratedColumn<String>(
    'chat_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatUpdatedAtMeta = const VerificationMeta(
    'chatUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> chatUpdatedAt =
      GeneratedColumn<DateTime>(
        'chat_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    chatId,
    userId,
    title,
    avatarUrl,
    lastMessage,
    lastMessageTime,
    unreadCount,
    chatType,
    chatName,
    chatGroupId,
    chatUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chat_previews';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChatPreview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
        _lastMessageTimeMeta,
        lastMessageTime.isAcceptableOrUnknown(
          data['last_message_time']!,
          _lastMessageTimeMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('chat_type')) {
      context.handle(
        _chatTypeMeta,
        chatType.isAcceptableOrUnknown(data['chat_type']!, _chatTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_chatTypeMeta);
    }
    if (data.containsKey('chat_name')) {
      context.handle(
        _chatNameMeta,
        chatName.isAcceptableOrUnknown(data['chat_name']!, _chatNameMeta),
      );
    }
    if (data.containsKey('chat_group_id')) {
      context.handle(
        _chatGroupIdMeta,
        chatGroupId.isAcceptableOrUnknown(
          data['chat_group_id']!,
          _chatGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('chat_updated_at')) {
      context.handle(
        _chatUpdatedAtMeta,
        chatUpdatedAt.isAcceptableOrUnknown(
          data['chat_updated_at']!,
          _chatUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, userId};
  @override
  LocalChatPreview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChatPreview(
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      lastMessageTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_time'],
      ),
      unreadCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}unread_count'],
          )!,
      chatType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_type'],
          )!,
      chatName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_name'],
      ),
      chatGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_group_id'],
      ),
      chatUpdatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}chat_updated_at'],
          )!,
    );
  }

  @override
  $LocalChatPreviewsTable createAlias(String alias) {
    return $LocalChatPreviewsTable(attachedDatabase, alias);
  }
}

class LocalChatPreview extends DataClass
    implements Insertable<LocalChatPreview> {
  final String chatId;
  final String userId;
  final String title;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String chatType;
  final String? chatName;
  final String? chatGroupId;
  final DateTime chatUpdatedAt;
  const LocalChatPreview({
    required this.chatId,
    required this.userId,
    required this.title,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.chatType,
    this.chatName,
    this.chatGroupId,
    required this.chatUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<String>(chatId);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['chat_type'] = Variable<String>(chatType);
    if (!nullToAbsent || chatName != null) {
      map['chat_name'] = Variable<String>(chatName);
    }
    if (!nullToAbsent || chatGroupId != null) {
      map['chat_group_id'] = Variable<String>(chatGroupId);
    }
    map['chat_updated_at'] = Variable<DateTime>(chatUpdatedAt);
    return map;
  }

  LocalChatPreviewsCompanion toCompanion(bool nullToAbsent) {
    return LocalChatPreviewsCompanion(
      chatId: Value(chatId),
      userId: Value(userId),
      title: Value(title),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
      lastMessage:
          lastMessage == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMessage),
      lastMessageTime:
          lastMessageTime == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMessageTime),
      unreadCount: Value(unreadCount),
      chatType: Value(chatType),
      chatName:
          chatName == null && nullToAbsent
              ? const Value.absent()
              : Value(chatName),
      chatGroupId:
          chatGroupId == null && nullToAbsent
              ? const Value.absent()
              : Value(chatGroupId),
      chatUpdatedAt: Value(chatUpdatedAt),
    );
  }

  factory LocalChatPreview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChatPreview(
      chatId: serializer.fromJson<String>(json['chatId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageTime: serializer.fromJson<DateTime?>(json['lastMessageTime']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      chatType: serializer.fromJson<String>(json['chatType']),
      chatName: serializer.fromJson<String?>(json['chatName']),
      chatGroupId: serializer.fromJson<String?>(json['chatGroupId']),
      chatUpdatedAt: serializer.fromJson<DateTime>(json['chatUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<String>(chatId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageTime': serializer.toJson<DateTime?>(lastMessageTime),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'chatType': serializer.toJson<String>(chatType),
      'chatName': serializer.toJson<String?>(chatName),
      'chatGroupId': serializer.toJson<String?>(chatGroupId),
      'chatUpdatedAt': serializer.toJson<DateTime>(chatUpdatedAt),
    };
  }

  LocalChatPreview copyWith({
    String? chatId,
    String? userId,
    String? title,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> lastMessage = const Value.absent(),
    Value<DateTime?> lastMessageTime = const Value.absent(),
    int? unreadCount,
    String? chatType,
    Value<String?> chatName = const Value.absent(),
    Value<String?> chatGroupId = const Value.absent(),
    DateTime? chatUpdatedAt,
  }) => LocalChatPreview(
    chatId: chatId ?? this.chatId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    lastMessageTime:
        lastMessageTime.present ? lastMessageTime.value : this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
    chatType: chatType ?? this.chatType,
    chatName: chatName.present ? chatName.value : this.chatName,
    chatGroupId: chatGroupId.present ? chatGroupId.value : this.chatGroupId,
    chatUpdatedAt: chatUpdatedAt ?? this.chatUpdatedAt,
  );
  LocalChatPreview copyWithCompanion(LocalChatPreviewsCompanion data) {
    return LocalChatPreview(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastMessageTime:
          data.lastMessageTime.present
              ? data.lastMessageTime.value
              : this.lastMessageTime,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      chatType: data.chatType.present ? data.chatType.value : this.chatType,
      chatName: data.chatName.present ? data.chatName.value : this.chatName,
      chatGroupId:
          data.chatGroupId.present ? data.chatGroupId.value : this.chatGroupId,
      chatUpdatedAt:
          data.chatUpdatedAt.present
              ? data.chatUpdatedAt.value
              : this.chatUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatPreview(')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('chatType: $chatType, ')
          ..write('chatName: $chatName, ')
          ..write('chatGroupId: $chatGroupId, ')
          ..write('chatUpdatedAt: $chatUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chatId,
    userId,
    title,
    avatarUrl,
    lastMessage,
    lastMessageTime,
    unreadCount,
    chatType,
    chatName,
    chatGroupId,
    chatUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChatPreview &&
          other.chatId == this.chatId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.avatarUrl == this.avatarUrl &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageTime == this.lastMessageTime &&
          other.unreadCount == this.unreadCount &&
          other.chatType == this.chatType &&
          other.chatName == this.chatName &&
          other.chatGroupId == this.chatGroupId &&
          other.chatUpdatedAt == this.chatUpdatedAt);
}

class LocalChatPreviewsCompanion extends UpdateCompanion<LocalChatPreview> {
  final Value<String> chatId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> avatarUrl;
  final Value<String?> lastMessage;
  final Value<DateTime?> lastMessageTime;
  final Value<int> unreadCount;
  final Value<String> chatType;
  final Value<String?> chatName;
  final Value<String?> chatGroupId;
  final Value<DateTime> chatUpdatedAt;
  final Value<int> rowid;
  const LocalChatPreviewsCompanion({
    this.chatId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.chatType = const Value.absent(),
    this.chatName = const Value.absent(),
    this.chatGroupId = const Value.absent(),
    this.chatUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChatPreviewsCompanion.insert({
    required String chatId,
    required String userId,
    required String title,
    this.avatarUrl = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    required String chatType,
    this.chatName = const Value.absent(),
    this.chatGroupId = const Value.absent(),
    required DateTime chatUpdatedAt,
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       userId = Value(userId),
       title = Value(title),
       chatType = Value(chatType),
       chatUpdatedAt = Value(chatUpdatedAt);
  static Insertable<LocalChatPreview> custom({
    Expression<String>? chatId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? avatarUrl,
    Expression<String>? lastMessage,
    Expression<DateTime>? lastMessageTime,
    Expression<int>? unreadCount,
    Expression<String>? chatType,
    Expression<String>? chatName,
    Expression<String>? chatGroupId,
    Expression<DateTime>? chatUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (chatType != null) 'chat_type': chatType,
      if (chatName != null) 'chat_name': chatName,
      if (chatGroupId != null) 'chat_group_id': chatGroupId,
      if (chatUpdatedAt != null) 'chat_updated_at': chatUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChatPreviewsCompanion copyWith({
    Value<String>? chatId,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? avatarUrl,
    Value<String?>? lastMessage,
    Value<DateTime?>? lastMessageTime,
    Value<int>? unreadCount,
    Value<String>? chatType,
    Value<String?>? chatName,
    Value<String?>? chatGroupId,
    Value<DateTime>? chatUpdatedAt,
    Value<int>? rowid,
  }) {
    return LocalChatPreviewsCompanion(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      chatType: chatType ?? this.chatType,
      chatName: chatName ?? this.chatName,
      chatGroupId: chatGroupId ?? this.chatGroupId,
      chatUpdatedAt: chatUpdatedAt ?? this.chatUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (chatType.present) {
      map['chat_type'] = Variable<String>(chatType.value);
    }
    if (chatName.present) {
      map['chat_name'] = Variable<String>(chatName.value);
    }
    if (chatGroupId.present) {
      map['chat_group_id'] = Variable<String>(chatGroupId.value);
    }
    if (chatUpdatedAt.present) {
      map['chat_updated_at'] = Variable<DateTime>(chatUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatPreviewsCompanion(')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('chatType: $chatType, ')
          ..write('chatName: $chatName, ')
          ..write('chatGroupId: $chatGroupId, ')
          ..write('chatUpdatedAt: $chatUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalRoomsTable localRooms = $LocalRoomsTable(this);
  late final $LocalSubjectsTable localSubjects = $LocalSubjectsTable(this);
  late final $LocalGroupsTable localGroups = $LocalGroupsTable(this);
  late final $LocalTeachersTable localTeachers = $LocalTeachersTable(this);
  late final $LocalSchedulesTable localSchedules = $LocalSchedulesTable(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalGradesTable localGrades = $LocalGradesTable(this);
  late final $LocalHomeworksTable localHomeworks = $LocalHomeworksTable(this);
  late final $LocalHomeworkStatusesTable localHomeworkStatuses =
      $LocalHomeworkStatusesTable(this);
  late final $LocalStudentsTable localStudents = $LocalStudentsTable(this);
  late final $LocalGroupDetailsTable localGroupDetails =
      $LocalGroupDetailsTable(this);
  late final $LocalTeacherProfilesTable localTeacherProfiles =
      $LocalTeacherProfilesTable(this);
  late final $LocalAdminProfilesTable localAdminProfiles =
      $LocalAdminProfilesTable(this);
  late final $LocalInstitutionsTable localInstitutions =
      $LocalInstitutionsTable(this);
  late final $LocalLessonsTable localLessons = $LocalLessonsTable(this);
  late final $LocalLessonAttendancesTable localLessonAttendances =
      $LocalLessonAttendancesTable(this);
  late final $LocalChatsTable localChats = $LocalChatsTable(this);
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  late final $LocalChatPreviewsTable localChatPreviews =
      $LocalChatPreviewsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localRooms,
    localSubjects,
    localGroups,
    localTeachers,
    localSchedules,
    localUsers,
    localGrades,
    localHomeworks,
    localHomeworkStatuses,
    localStudents,
    localGroupDetails,
    localTeacherProfiles,
    localAdminProfiles,
    localInstitutions,
    localLessons,
    localLessonAttendances,
    localChats,
    localMessages,
    localChatPreviews,
  ];
}

typedef $$LocalRoomsTableCreateCompanionBuilder =
    LocalRoomsCompanion Function({
      required String id,
      required String name,
      required String institutionId,
      Value<int> rowid,
    });
typedef $$LocalRoomsTableUpdateCompanionBuilder =
    LocalRoomsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> institutionId,
      Value<int> rowid,
    });

final class $$LocalRoomsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalRoomsTable, LocalRoom> {
  $$LocalRoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalSchedulesTable, List<LocalSchedule>>
  _localSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localSchedules,
    aliasName: $_aliasNameGenerator(db.localRooms.id, db.localSchedules.roomId),
  );

  $$LocalSchedulesTableProcessedTableManager get localSchedulesRefs {
    final manager = $$LocalSchedulesTableTableManager(
      $_db,
      $_db.localSchedules,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localSchedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localSchedulesRefs(
    Expression<bool> Function($$LocalSchedulesTableFilterComposer f) f,
  ) {
    final $$LocalSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  Expression<T> localSchedulesRefs<T extends Object>(
    Expression<T> Function($$LocalSchedulesTableAnnotationComposer a) f,
  ) {
    final $$LocalSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRoomsTable,
          LocalRoom,
          $$LocalRoomsTableFilterComposer,
          $$LocalRoomsTableOrderingComposer,
          $$LocalRoomsTableAnnotationComposer,
          $$LocalRoomsTableCreateCompanionBuilder,
          $$LocalRoomsTableUpdateCompanionBuilder,
          (LocalRoom, $$LocalRoomsTableReferences),
          LocalRoom,
          PrefetchHooks Function({bool localSchedulesRefs})
        > {
  $$LocalRoomsTableTableManager(_$AppDatabase db, $LocalRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRoomsCompanion(
                id: id,
                name: name,
                institutionId: institutionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String institutionId,
                Value<int> rowid = const Value.absent(),
              }) => LocalRoomsCompanion.insert(
                id: id,
                name: name,
                institutionId: institutionId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalRoomsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({localSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localSchedulesRefs) db.localSchedules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localSchedulesRefs)
                    await $_getPrefetchedData<
                      LocalRoom,
                      $LocalRoomsTable,
                      LocalSchedule
                    >(
                      currentTable: table,
                      referencedTable: $$LocalRoomsTableReferences
                          ._localSchedulesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocalRoomsTableReferences(
                                db,
                                table,
                                p0,
                              ).localSchedulesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.roomId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRoomsTable,
      LocalRoom,
      $$LocalRoomsTableFilterComposer,
      $$LocalRoomsTableOrderingComposer,
      $$LocalRoomsTableAnnotationComposer,
      $$LocalRoomsTableCreateCompanionBuilder,
      $$LocalRoomsTableUpdateCompanionBuilder,
      (LocalRoom, $$LocalRoomsTableReferences),
      LocalRoom,
      PrefetchHooks Function({bool localSchedulesRefs})
    >;
typedef $$LocalSubjectsTableCreateCompanionBuilder =
    LocalSubjectsCompanion Function({
      required String id,
      required String name,
      required String institutionId,
      Value<int> rowid,
    });
typedef $$LocalSubjectsTableUpdateCompanionBuilder =
    LocalSubjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> institutionId,
      Value<int> rowid,
    });

final class $$LocalSubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalSubjectsTable, LocalSubject> {
  $$LocalSubjectsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalSchedulesTable, List<LocalSchedule>>
  _localSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localSchedules,
    aliasName: $_aliasNameGenerator(
      db.localSubjects.id,
      db.localSchedules.subjectId,
    ),
  );

  $$LocalSchedulesTableProcessedTableManager get localSchedulesRefs {
    final manager = $$LocalSchedulesTableTableManager(
      $_db,
      $_db.localSchedules,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localSchedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localSchedulesRefs(
    Expression<bool> Function($$LocalSchedulesTableFilterComposer f) f,
  ) {
    final $$LocalSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  Expression<T> localSchedulesRefs<T extends Object>(
    Expression<T> Function($$LocalSchedulesTableAnnotationComposer a) f,
  ) {
    final $$LocalSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSubjectsTable,
          LocalSubject,
          $$LocalSubjectsTableFilterComposer,
          $$LocalSubjectsTableOrderingComposer,
          $$LocalSubjectsTableAnnotationComposer,
          $$LocalSubjectsTableCreateCompanionBuilder,
          $$LocalSubjectsTableUpdateCompanionBuilder,
          (LocalSubject, $$LocalSubjectsTableReferences),
          LocalSubject,
          PrefetchHooks Function({bool localSchedulesRefs})
        > {
  $$LocalSubjectsTableTableManager(_$AppDatabase db, $LocalSubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalSubjectsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSubjectsCompanion(
                id: id,
                name: name,
                institutionId: institutionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String institutionId,
                Value<int> rowid = const Value.absent(),
              }) => LocalSubjectsCompanion.insert(
                id: id,
                name: name,
                institutionId: institutionId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalSubjectsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({localSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localSchedulesRefs) db.localSchedules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localSchedulesRefs)
                    await $_getPrefetchedData<
                      LocalSubject,
                      $LocalSubjectsTable,
                      LocalSchedule
                    >(
                      currentTable: table,
                      referencedTable: $$LocalSubjectsTableReferences
                          ._localSchedulesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocalSubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).localSchedulesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.subjectId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSubjectsTable,
      LocalSubject,
      $$LocalSubjectsTableFilterComposer,
      $$LocalSubjectsTableOrderingComposer,
      $$LocalSubjectsTableAnnotationComposer,
      $$LocalSubjectsTableCreateCompanionBuilder,
      $$LocalSubjectsTableUpdateCompanionBuilder,
      (LocalSubject, $$LocalSubjectsTableReferences),
      LocalSubject,
      PrefetchHooks Function({bool localSchedulesRefs})
    >;
typedef $$LocalGroupsTableCreateCompanionBuilder =
    LocalGroupsCompanion Function({
      required String id,
      required String name,
      required String institutionId,
      Value<int> rowid,
    });
typedef $$LocalGroupsTableUpdateCompanionBuilder =
    LocalGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> institutionId,
      Value<int> rowid,
    });

final class $$LocalGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalGroupsTable, LocalGroup> {
  $$LocalGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalSchedulesTable, List<LocalSchedule>>
  _localSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localSchedules,
    aliasName: $_aliasNameGenerator(
      db.localGroups.id,
      db.localSchedules.groupId,
    ),
  );

  $$LocalSchedulesTableProcessedTableManager get localSchedulesRefs {
    final manager = $$LocalSchedulesTableTableManager(
      $_db,
      $_db.localSchedules,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localSchedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localSchedulesRefs(
    Expression<bool> Function($$LocalSchedulesTableFilterComposer f) f,
  ) {
    final $$LocalSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  Expression<T> localSchedulesRefs<T extends Object>(
    Expression<T> Function($$LocalSchedulesTableAnnotationComposer a) f,
  ) {
    final $$LocalSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGroupsTable,
          LocalGroup,
          $$LocalGroupsTableFilterComposer,
          $$LocalGroupsTableOrderingComposer,
          $$LocalGroupsTableAnnotationComposer,
          $$LocalGroupsTableCreateCompanionBuilder,
          $$LocalGroupsTableUpdateCompanionBuilder,
          (LocalGroup, $$LocalGroupsTableReferences),
          LocalGroup,
          PrefetchHooks Function({bool localSchedulesRefs})
        > {
  $$LocalGroupsTableTableManager(_$AppDatabase db, $LocalGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$LocalGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGroupsCompanion(
                id: id,
                name: name,
                institutionId: institutionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String institutionId,
                Value<int> rowid = const Value.absent(),
              }) => LocalGroupsCompanion.insert(
                id: id,
                name: name,
                institutionId: institutionId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalGroupsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({localSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localSchedulesRefs) db.localSchedules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localSchedulesRefs)
                    await $_getPrefetchedData<
                      LocalGroup,
                      $LocalGroupsTable,
                      LocalSchedule
                    >(
                      currentTable: table,
                      referencedTable: $$LocalGroupsTableReferences
                          ._localSchedulesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocalGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).localSchedulesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.groupId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGroupsTable,
      LocalGroup,
      $$LocalGroupsTableFilterComposer,
      $$LocalGroupsTableOrderingComposer,
      $$LocalGroupsTableAnnotationComposer,
      $$LocalGroupsTableCreateCompanionBuilder,
      $$LocalGroupsTableUpdateCompanionBuilder,
      (LocalGroup, $$LocalGroupsTableReferences),
      LocalGroup,
      PrefetchHooks Function({bool localSchedulesRefs})
    >;
typedef $$LocalTeachersTableCreateCompanionBuilder =
    LocalTeachersCompanion Function({
      required String id,
      required String name,
      required String surname,
      Value<int> rowid,
    });
typedef $$LocalTeachersTableUpdateCompanionBuilder =
    LocalTeachersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> surname,
      Value<int> rowid,
    });

final class $$LocalTeachersTableReferences
    extends BaseReferences<_$AppDatabase, $LocalTeachersTable, LocalTeacher> {
  $$LocalTeachersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalSchedulesTable, List<LocalSchedule>>
  _localSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localSchedules,
    aliasName: $_aliasNameGenerator(
      db.localTeachers.id,
      db.localSchedules.teacherId,
    ),
  );

  $$LocalSchedulesTableProcessedTableManager get localSchedulesRefs {
    final manager = $$LocalSchedulesTableTableManager(
      $_db,
      $_db.localSchedules,
    ).filter((f) => f.teacherId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localSchedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalTeachersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTeachersTable> {
  $$LocalTeachersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localSchedulesRefs(
    Expression<bool> Function($$LocalSchedulesTableFilterComposer f) f,
  ) {
    final $$LocalSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.teacherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalTeachersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTeachersTable> {
  $$LocalTeachersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTeachersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTeachersTable> {
  $$LocalTeachersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  Expression<T> localSchedulesRefs<T extends Object>(
    Expression<T> Function($$LocalSchedulesTableAnnotationComposer a) f,
  ) {
    final $$LocalSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSchedules,
      getReferencedColumn: (t) => t.teacherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.localSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalTeachersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTeachersTable,
          LocalTeacher,
          $$LocalTeachersTableFilterComposer,
          $$LocalTeachersTableOrderingComposer,
          $$LocalTeachersTableAnnotationComposer,
          $$LocalTeachersTableCreateCompanionBuilder,
          $$LocalTeachersTableUpdateCompanionBuilder,
          (LocalTeacher, $$LocalTeachersTableReferences),
          LocalTeacher,
          PrefetchHooks Function({bool localSchedulesRefs})
        > {
  $$LocalTeachersTableTableManager(_$AppDatabase db, $LocalTeachersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalTeachersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalTeachersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalTeachersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTeachersCompanion(
                id: id,
                name: name,
                surname: surname,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String surname,
                Value<int> rowid = const Value.absent(),
              }) => LocalTeachersCompanion.insert(
                id: id,
                name: name,
                surname: surname,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalTeachersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({localSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localSchedulesRefs) db.localSchedules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localSchedulesRefs)
                    await $_getPrefetchedData<
                      LocalTeacher,
                      $LocalTeachersTable,
                      LocalSchedule
                    >(
                      currentTable: table,
                      referencedTable: $$LocalTeachersTableReferences
                          ._localSchedulesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocalTeachersTableReferences(
                                db,
                                table,
                                p0,
                              ).localSchedulesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.teacherId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalTeachersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTeachersTable,
      LocalTeacher,
      $$LocalTeachersTableFilterComposer,
      $$LocalTeachersTableOrderingComposer,
      $$LocalTeachersTableAnnotationComposer,
      $$LocalTeachersTableCreateCompanionBuilder,
      $$LocalTeachersTableUpdateCompanionBuilder,
      (LocalTeacher, $$LocalTeachersTableReferences),
      LocalTeacher,
      PrefetchHooks Function({bool localSchedulesRefs})
    >;
typedef $$LocalSchedulesTableCreateCompanionBuilder =
    LocalSchedulesCompanion Function({
      required String id,
      required String institutionId,
      required String subjectId,
      required String groupId,
      required String teacherId,
      Value<String?> roomId,
      Value<DateTime?> date,
      required int weekday,
      required String startTime,
      required String endTime,
      Value<int> rowid,
    });
typedef $$LocalSchedulesTableUpdateCompanionBuilder =
    LocalSchedulesCompanion Function({
      Value<String> id,
      Value<String> institutionId,
      Value<String> subjectId,
      Value<String> groupId,
      Value<String> teacherId,
      Value<String?> roomId,
      Value<DateTime?> date,
      Value<int> weekday,
      Value<String> startTime,
      Value<String> endTime,
      Value<int> rowid,
    });

final class $$LocalSchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalSchedulesTable, LocalSchedule> {
  $$LocalSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalSubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.localSubjects.createAlias(
        $_aliasNameGenerator(db.localSchedules.subjectId, db.localSubjects.id),
      );

  $$LocalSubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<String>('subject_id')!;

    final manager = $$LocalSubjectsTableTableManager(
      $_db,
      $_db.localSubjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.localGroups.createAlias(
        $_aliasNameGenerator(db.localSchedules.groupId, db.localGroups.id),
      );

  $$LocalGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$LocalGroupsTableTableManager(
      $_db,
      $_db.localGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalTeachersTable _teacherIdTable(_$AppDatabase db) =>
      db.localTeachers.createAlias(
        $_aliasNameGenerator(db.localSchedules.teacherId, db.localTeachers.id),
      );

  $$LocalTeachersTableProcessedTableManager get teacherId {
    final $_column = $_itemColumn<String>('teacher_id')!;

    final manager = $$LocalTeachersTableTableManager(
      $_db,
      $_db.localTeachers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teacherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalRoomsTable _roomIdTable(_$AppDatabase db) =>
      db.localRooms.createAlias(
        $_aliasNameGenerator(db.localSchedules.roomId, db.localRooms.id),
      );

  $$LocalRoomsTableProcessedTableManager? get roomId {
    final $_column = $_itemColumn<String>('room_id');
    if ($_column == null) return null;
    final manager = $$LocalRoomsTableTableManager(
      $_db,
      $_db.localRooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSchedulesTable> {
  $$LocalSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalSubjectsTableFilterComposer get subjectId {
    final $$LocalSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.localSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.localSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalGroupsTableFilterComposer get groupId {
    final $$LocalGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.localGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalGroupsTableFilterComposer(
            $db: $db,
            $table: $db.localGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalTeachersTableFilterComposer get teacherId {
    final $$LocalTeachersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teacherId,
      referencedTable: $db.localTeachers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalTeachersTableFilterComposer(
            $db: $db,
            $table: $db.localTeachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalRoomsTableFilterComposer get roomId {
    final $$LocalRoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.localRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRoomsTableFilterComposer(
            $db: $db,
            $table: $db.localRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSchedulesTable> {
  $$LocalSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalSubjectsTableOrderingComposer get subjectId {
    final $$LocalSubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.localSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.localSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalGroupsTableOrderingComposer get groupId {
    final $$LocalGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.localGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.localGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalTeachersTableOrderingComposer get teacherId {
    final $$LocalTeachersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teacherId,
      referencedTable: $db.localTeachers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalTeachersTableOrderingComposer(
            $db: $db,
            $table: $db.localTeachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalRoomsTableOrderingComposer get roomId {
    final $$LocalRoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.localRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRoomsTableOrderingComposer(
            $db: $db,
            $table: $db.localRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSchedulesTable> {
  $$LocalSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  $$LocalSubjectsTableAnnotationComposer get subjectId {
    final $$LocalSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.localSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.localSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalGroupsTableAnnotationComposer get groupId {
    final $$LocalGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.localGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.localGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalTeachersTableAnnotationComposer get teacherId {
    final $$LocalTeachersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teacherId,
      referencedTable: $db.localTeachers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalTeachersTableAnnotationComposer(
            $db: $db,
            $table: $db.localTeachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalRoomsTableAnnotationComposer get roomId {
    final $$LocalRoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.localRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.localRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSchedulesTable,
          LocalSchedule,
          $$LocalSchedulesTableFilterComposer,
          $$LocalSchedulesTableOrderingComposer,
          $$LocalSchedulesTableAnnotationComposer,
          $$LocalSchedulesTableCreateCompanionBuilder,
          $$LocalSchedulesTableUpdateCompanionBuilder,
          (LocalSchedule, $$LocalSchedulesTableReferences),
          LocalSchedule,
          PrefetchHooks Function({
            bool subjectId,
            bool groupId,
            bool teacherId,
            bool roomId,
          })
        > {
  $$LocalSchedulesTableTableManager(
    _$AppDatabase db,
    $LocalSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSchedulesCompanion(
                id: id,
                institutionId: institutionId,
                subjectId: subjectId,
                groupId: groupId,
                teacherId: teacherId,
                roomId: roomId,
                date: date,
                weekday: weekday,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String institutionId,
                required String subjectId,
                required String groupId,
                required String teacherId,
                Value<String?> roomId = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                required int weekday,
                required String startTime,
                required String endTime,
                Value<int> rowid = const Value.absent(),
              }) => LocalSchedulesCompanion.insert(
                id: id,
                institutionId: institutionId,
                subjectId: subjectId,
                groupId: groupId,
                teacherId: teacherId,
                roomId: roomId,
                date: date,
                weekday: weekday,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalSchedulesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            subjectId = false,
            groupId = false,
            teacherId = false,
            roomId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (subjectId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$LocalSchedulesTableReferences
                                ._subjectIdTable(db),
                            referencedColumn:
                                $$LocalSchedulesTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (groupId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$LocalSchedulesTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$LocalSchedulesTableReferences
                                    ._groupIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (teacherId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.teacherId,
                            referencedTable: $$LocalSchedulesTableReferences
                                ._teacherIdTable(db),
                            referencedColumn:
                                $$LocalSchedulesTableReferences
                                    ._teacherIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (roomId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.roomId,
                            referencedTable: $$LocalSchedulesTableReferences
                                ._roomIdTable(db),
                            referencedColumn:
                                $$LocalSchedulesTableReferences
                                    ._roomIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSchedulesTable,
      LocalSchedule,
      $$LocalSchedulesTableFilterComposer,
      $$LocalSchedulesTableOrderingComposer,
      $$LocalSchedulesTableAnnotationComposer,
      $$LocalSchedulesTableCreateCompanionBuilder,
      $$LocalSchedulesTableUpdateCompanionBuilder,
      (LocalSchedule, $$LocalSchedulesTableReferences),
      LocalSchedule,
      PrefetchHooks Function({
        bool subjectId,
        bool groupId,
        bool teacherId,
        bool roomId,
      })
    >;
typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String id,
      required String role,
      Value<String?> name,
      Value<String?> surname,
      Value<String?> email,
      Value<String?> login,
      required String institutionId,
      Value<String?> groupId,
      Value<String?> avatarUrl,
      Value<String?> institutionName,
      Value<String?> groupName,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> id,
      Value<String> role,
      Value<String?> name,
      Value<String?> surname,
      Value<String?> email,
      Value<String?> login,
      Value<String> institutionId,
      Value<String?> groupId,
      Value<String?> avatarUrl,
      Value<String?> institutionName,
      Value<String?> groupName,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> surname = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> login = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> institutionName = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                role: role,
                name: name,
                surname: surname,
                email: email,
                login: login,
                institutionId: institutionId,
                groupId: groupId,
                avatarUrl: avatarUrl,
                institutionName: institutionName,
                groupName: groupName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String role,
                Value<String?> name = const Value.absent(),
                Value<String?> surname = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> login = const Value.absent(),
                required String institutionId,
                Value<String?> groupId = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> institutionName = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                role: role,
                name: name,
                surname: surname,
                email: email,
                login: login,
                institutionId: institutionId,
                groupId: groupId,
                avatarUrl: avatarUrl,
                institutionName: institutionName,
                groupName: groupName,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalGradesTableCreateCompanionBuilder =
    LocalGradesCompanion Function({
      required String id,
      required String lessonId,
      required String studentId,
      required int value,
      Value<int> rowid,
    });
typedef $$LocalGradesTableUpdateCompanionBuilder =
    LocalGradesCompanion Function({
      Value<String> id,
      Value<String> lessonId,
      Value<String> studentId,
      Value<int> value,
      Value<int> rowid,
    });

class $$LocalGradesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGradesTable> {
  $$LocalGradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalGradesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGradesTable> {
  $$LocalGradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalGradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGradesTable> {
  $$LocalGradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalGradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGradesTable,
          LocalGrade,
          $$LocalGradesTableFilterComposer,
          $$LocalGradesTableOrderingComposer,
          $$LocalGradesTableAnnotationComposer,
          $$LocalGradesTableCreateCompanionBuilder,
          $$LocalGradesTableUpdateCompanionBuilder,
          (
            LocalGrade,
            BaseReferences<_$AppDatabase, $LocalGradesTable, LocalGrade>,
          ),
          LocalGrade,
          PrefetchHooks Function()
        > {
  $$LocalGradesTableTableManager(_$AppDatabase db, $LocalGradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalGradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalGradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$LocalGradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGradesCompanion(
                id: id,
                lessonId: lessonId,
                studentId: studentId,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lessonId,
                required String studentId,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => LocalGradesCompanion.insert(
                id: id,
                lessonId: lessonId,
                studentId: studentId,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalGradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGradesTable,
      LocalGrade,
      $$LocalGradesTableFilterComposer,
      $$LocalGradesTableOrderingComposer,
      $$LocalGradesTableAnnotationComposer,
      $$LocalGradesTableCreateCompanionBuilder,
      $$LocalGradesTableUpdateCompanionBuilder,
      (
        LocalGrade,
        BaseReferences<_$AppDatabase, $LocalGradesTable, LocalGrade>,
      ),
      LocalGrade,
      PrefetchHooks Function()
    >;
typedef $$LocalHomeworksTableCreateCompanionBuilder =
    LocalHomeworksCompanion Function({
      required String id,
      required String subjectId,
      required String groupId,
      Value<String?> lessonId,
      required String title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<DateTime?> createdAt,
      Value<String?> fileUrl,
      Value<String?> fileName,
      Value<int> rowid,
    });
typedef $$LocalHomeworksTableUpdateCompanionBuilder =
    LocalHomeworksCompanion Function({
      Value<String> id,
      Value<String> subjectId,
      Value<String> groupId,
      Value<String?> lessonId,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<DateTime?> createdAt,
      Value<String?> fileUrl,
      Value<String?> fileName,
      Value<int> rowid,
    });

class $$LocalHomeworksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHomeworksTable> {
  $$LocalHomeworksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHomeworksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHomeworksTable> {
  $$LocalHomeworksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHomeworksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHomeworksTable> {
  $$LocalHomeworksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);
}

class $$LocalHomeworksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalHomeworksTable,
          LocalHomework,
          $$LocalHomeworksTableFilterComposer,
          $$LocalHomeworksTableOrderingComposer,
          $$LocalHomeworksTableAnnotationComposer,
          $$LocalHomeworksTableCreateCompanionBuilder,
          $$LocalHomeworksTableUpdateCompanionBuilder,
          (
            LocalHomework,
            BaseReferences<_$AppDatabase, $LocalHomeworksTable, LocalHomework>,
          ),
          LocalHomework,
          PrefetchHooks Function()
        > {
  $$LocalHomeworksTableTableManager(
    _$AppDatabase db,
    $LocalHomeworksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalHomeworksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalHomeworksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalHomeworksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String?> lessonId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> fileUrl = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHomeworksCompanion(
                id: id,
                subjectId: subjectId,
                groupId: groupId,
                lessonId: lessonId,
                title: title,
                description: description,
                dueDate: dueDate,
                createdAt: createdAt,
                fileUrl: fileUrl,
                fileName: fileName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required String groupId,
                Value<String?> lessonId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> fileUrl = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHomeworksCompanion.insert(
                id: id,
                subjectId: subjectId,
                groupId: groupId,
                lessonId: lessonId,
                title: title,
                description: description,
                dueDate: dueDate,
                createdAt: createdAt,
                fileUrl: fileUrl,
                fileName: fileName,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHomeworksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalHomeworksTable,
      LocalHomework,
      $$LocalHomeworksTableFilterComposer,
      $$LocalHomeworksTableOrderingComposer,
      $$LocalHomeworksTableAnnotationComposer,
      $$LocalHomeworksTableCreateCompanionBuilder,
      $$LocalHomeworksTableUpdateCompanionBuilder,
      (
        LocalHomework,
        BaseReferences<_$AppDatabase, $LocalHomeworksTable, LocalHomework>,
      ),
      LocalHomework,
      PrefetchHooks Function()
    >;
typedef $$LocalHomeworkStatusesTableCreateCompanionBuilder =
    LocalHomeworkStatusesCompanion Function({
      required String id,
      required String homeworkId,
      required String studentId,
      required bool isCompleted,
      Value<String?> studentComment,
      Value<String?> teacherComment,
      Value<String?> fileUrl,
      Value<String?> fileName,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalHomeworkStatusesTableUpdateCompanionBuilder =
    LocalHomeworkStatusesCompanion Function({
      Value<String> id,
      Value<String> homeworkId,
      Value<String> studentId,
      Value<bool> isCompleted,
      Value<String?> studentComment,
      Value<String?> teacherComment,
      Value<String?> fileUrl,
      Value<String?> fileName,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalHomeworkStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHomeworkStatusesTable> {
  $$LocalHomeworkStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeworkId => $composableBuilder(
    column: $table.homeworkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentComment => $composableBuilder(
    column: $table.studentComment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherComment => $composableBuilder(
    column: $table.teacherComment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHomeworkStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHomeworkStatusesTable> {
  $$LocalHomeworkStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeworkId => $composableBuilder(
    column: $table.homeworkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentComment => $composableBuilder(
    column: $table.studentComment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherComment => $composableBuilder(
    column: $table.teacherComment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHomeworkStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHomeworkStatusesTable> {
  $$LocalHomeworkStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get homeworkId => $composableBuilder(
    column: $table.homeworkId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentComment => $composableBuilder(
    column: $table.studentComment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherComment => $composableBuilder(
    column: $table.teacherComment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalHomeworkStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalHomeworkStatusesTable,
          LocalHomeworkStatuse,
          $$LocalHomeworkStatusesTableFilterComposer,
          $$LocalHomeworkStatusesTableOrderingComposer,
          $$LocalHomeworkStatusesTableAnnotationComposer,
          $$LocalHomeworkStatusesTableCreateCompanionBuilder,
          $$LocalHomeworkStatusesTableUpdateCompanionBuilder,
          (
            LocalHomeworkStatuse,
            BaseReferences<
              _$AppDatabase,
              $LocalHomeworkStatusesTable,
              LocalHomeworkStatuse
            >,
          ),
          LocalHomeworkStatuse,
          PrefetchHooks Function()
        > {
  $$LocalHomeworkStatusesTableTableManager(
    _$AppDatabase db,
    $LocalHomeworkStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalHomeworkStatusesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalHomeworkStatusesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalHomeworkStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeworkId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String?> studentComment = const Value.absent(),
                Value<String?> teacherComment = const Value.absent(),
                Value<String?> fileUrl = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHomeworkStatusesCompanion(
                id: id,
                homeworkId: homeworkId,
                studentId: studentId,
                isCompleted: isCompleted,
                studentComment: studentComment,
                teacherComment: teacherComment,
                fileUrl: fileUrl,
                fileName: fileName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String homeworkId,
                required String studentId,
                required bool isCompleted,
                Value<String?> studentComment = const Value.absent(),
                Value<String?> teacherComment = const Value.absent(),
                Value<String?> fileUrl = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalHomeworkStatusesCompanion.insert(
                id: id,
                homeworkId: homeworkId,
                studentId: studentId,
                isCompleted: isCompleted,
                studentComment: studentComment,
                teacherComment: teacherComment,
                fileUrl: fileUrl,
                fileName: fileName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHomeworkStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalHomeworkStatusesTable,
      LocalHomeworkStatuse,
      $$LocalHomeworkStatusesTableFilterComposer,
      $$LocalHomeworkStatusesTableOrderingComposer,
      $$LocalHomeworkStatusesTableAnnotationComposer,
      $$LocalHomeworkStatusesTableCreateCompanionBuilder,
      $$LocalHomeworkStatusesTableUpdateCompanionBuilder,
      (
        LocalHomeworkStatuse,
        BaseReferences<
          _$AppDatabase,
          $LocalHomeworkStatusesTable,
          LocalHomeworkStatuse
        >,
      ),
      LocalHomeworkStatuse,
      PrefetchHooks Function()
    >;
typedef $$LocalStudentsTableCreateCompanionBuilder =
    LocalStudentsCompanion Function({
      required String id,
      required String name,
      required String surname,
      required String email,
      required String login,
      Value<String?> groupId,
      Value<bool> isHeadman,
      required DateTime createdAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });
typedef $$LocalStudentsTableUpdateCompanionBuilder =
    LocalStudentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> surname,
      Value<String> email,
      Value<String> login,
      Value<String?> groupId,
      Value<bool> isHeadman,
      Value<DateTime> createdAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });

class $$LocalStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHeadman => $composableBuilder(
    column: $table.isHeadman,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHeadman => $composableBuilder(
    column: $table.isHeadman,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<bool> get isHeadman =>
      $composableBuilder(column: $table.isHeadman, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);
}

class $$LocalStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStudentsTable,
          LocalStudent,
          $$LocalStudentsTableFilterComposer,
          $$LocalStudentsTableOrderingComposer,
          $$LocalStudentsTableAnnotationComposer,
          $$LocalStudentsTableCreateCompanionBuilder,
          $$LocalStudentsTableUpdateCompanionBuilder,
          (
            LocalStudent,
            BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudent>,
          ),
          LocalStudent,
          PrefetchHooks Function()
        > {
  $$LocalStudentsTableTableManager(_$AppDatabase db, $LocalStudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalStudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalStudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalStudentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> login = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<bool> isHeadman = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentsCompanion(
                id: id,
                name: name,
                surname: surname,
                email: email,
                login: login,
                groupId: groupId,
                isHeadman: isHeadman,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String surname,
                required String email,
                required String login,
                Value<String?> groupId = const Value.absent(),
                Value<bool> isHeadman = const Value.absent(),
                required DateTime createdAt,
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentsCompanion.insert(
                id: id,
                name: name,
                surname: surname,
                email: email,
                login: login,
                groupId: groupId,
                isHeadman: isHeadman,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStudentsTable,
      LocalStudent,
      $$LocalStudentsTableFilterComposer,
      $$LocalStudentsTableOrderingComposer,
      $$LocalStudentsTableAnnotationComposer,
      $$LocalStudentsTableCreateCompanionBuilder,
      $$LocalStudentsTableUpdateCompanionBuilder,
      (
        LocalStudent,
        BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudent>,
      ),
      LocalStudent,
      PrefetchHooks Function()
    >;
typedef $$LocalGroupDetailsTableCreateCompanionBuilder =
    LocalGroupDetailsCompanion Function({
      required String id,
      required String name,
      required String institutionId,
      Value<String?> curatorId,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$LocalGroupDetailsTableUpdateCompanionBuilder =
    LocalGroupDetailsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> institutionId,
      Value<String?> curatorId,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$LocalGroupDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGroupDetailsTable> {
  $$LocalGroupDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get curatorId => $composableBuilder(
    column: $table.curatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalGroupDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGroupDetailsTable> {
  $$LocalGroupDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get curatorId => $composableBuilder(
    column: $table.curatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalGroupDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGroupDetailsTable> {
  $$LocalGroupDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get curatorId =>
      $composableBuilder(column: $table.curatorId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalGroupDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGroupDetailsTable,
          LocalGroupDetail,
          $$LocalGroupDetailsTableFilterComposer,
          $$LocalGroupDetailsTableOrderingComposer,
          $$LocalGroupDetailsTableAnnotationComposer,
          $$LocalGroupDetailsTableCreateCompanionBuilder,
          $$LocalGroupDetailsTableUpdateCompanionBuilder,
          (
            LocalGroupDetail,
            BaseReferences<
              _$AppDatabase,
              $LocalGroupDetailsTable,
              LocalGroupDetail
            >,
          ),
          LocalGroupDetail,
          PrefetchHooks Function()
        > {
  $$LocalGroupDetailsTableTableManager(
    _$AppDatabase db,
    $LocalGroupDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalGroupDetailsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalGroupDetailsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalGroupDetailsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String?> curatorId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGroupDetailsCompanion(
                id: id,
                name: name,
                institutionId: institutionId,
                curatorId: curatorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String institutionId,
                Value<String?> curatorId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGroupDetailsCompanion.insert(
                id: id,
                name: name,
                institutionId: institutionId,
                curatorId: curatorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalGroupDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGroupDetailsTable,
      LocalGroupDetail,
      $$LocalGroupDetailsTableFilterComposer,
      $$LocalGroupDetailsTableOrderingComposer,
      $$LocalGroupDetailsTableAnnotationComposer,
      $$LocalGroupDetailsTableCreateCompanionBuilder,
      $$LocalGroupDetailsTableUpdateCompanionBuilder,
      (
        LocalGroupDetail,
        BaseReferences<
          _$AppDatabase,
          $LocalGroupDetailsTable,
          LocalGroupDetail
        >,
      ),
      LocalGroupDetail,
      PrefetchHooks Function()
    >;
typedef $$LocalTeacherProfilesTableCreateCompanionBuilder =
    LocalTeacherProfilesCompanion Function({
      required String id,
      required String name,
      required String surname,
      required String email,
      required String login,
      required String institutionId,
      Value<String?> department,
      required DateTime createdAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });
typedef $$LocalTeacherProfilesTableUpdateCompanionBuilder =
    LocalTeacherProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> surname,
      Value<String> email,
      Value<String> login,
      Value<String> institutionId,
      Value<String?> department,
      Value<DateTime> createdAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });

class $$LocalTeacherProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTeacherProfilesTable> {
  $$LocalTeacherProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTeacherProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTeacherProfilesTable> {
  $$LocalTeacherProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTeacherProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTeacherProfilesTable> {
  $$LocalTeacherProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);
}

class $$LocalTeacherProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTeacherProfilesTable,
          LocalTeacherProfile,
          $$LocalTeacherProfilesTableFilterComposer,
          $$LocalTeacherProfilesTableOrderingComposer,
          $$LocalTeacherProfilesTableAnnotationComposer,
          $$LocalTeacherProfilesTableCreateCompanionBuilder,
          $$LocalTeacherProfilesTableUpdateCompanionBuilder,
          (
            LocalTeacherProfile,
            BaseReferences<
              _$AppDatabase,
              $LocalTeacherProfilesTable,
              LocalTeacherProfile
            >,
          ),
          LocalTeacherProfile,
          PrefetchHooks Function()
        > {
  $$LocalTeacherProfilesTableTableManager(
    _$AppDatabase db,
    $LocalTeacherProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalTeacherProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalTeacherProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalTeacherProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> login = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTeacherProfilesCompanion(
                id: id,
                name: name,
                surname: surname,
                email: email,
                login: login,
                institutionId: institutionId,
                department: department,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String surname,
                required String email,
                required String login,
                required String institutionId,
                Value<String?> department = const Value.absent(),
                required DateTime createdAt,
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTeacherProfilesCompanion.insert(
                id: id,
                name: name,
                surname: surname,
                email: email,
                login: login,
                institutionId: institutionId,
                department: department,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTeacherProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTeacherProfilesTable,
      LocalTeacherProfile,
      $$LocalTeacherProfilesTableFilterComposer,
      $$LocalTeacherProfilesTableOrderingComposer,
      $$LocalTeacherProfilesTableAnnotationComposer,
      $$LocalTeacherProfilesTableCreateCompanionBuilder,
      $$LocalTeacherProfilesTableUpdateCompanionBuilder,
      (
        LocalTeacherProfile,
        BaseReferences<
          _$AppDatabase,
          $LocalTeacherProfilesTable,
          LocalTeacherProfile
        >,
      ),
      LocalTeacherProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalAdminProfilesTableCreateCompanionBuilder =
    LocalAdminProfilesCompanion Function({
      required String id,
      required String name,
      required String surname,
      required String email,
      required String login,
      required String institutionId,
      required String phone,
      required DateTime createdAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });
typedef $$LocalAdminProfilesTableUpdateCompanionBuilder =
    LocalAdminProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> surname,
      Value<String> email,
      Value<String> login,
      Value<String> institutionId,
      Value<String> phone,
      Value<DateTime> createdAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });

class $$LocalAdminProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAdminProfilesTable> {
  $$LocalAdminProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAdminProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAdminProfilesTable> {
  $$LocalAdminProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAdminProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAdminProfilesTable> {
  $$LocalAdminProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);
}

class $$LocalAdminProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAdminProfilesTable,
          LocalAdminProfile,
          $$LocalAdminProfilesTableFilterComposer,
          $$LocalAdminProfilesTableOrderingComposer,
          $$LocalAdminProfilesTableAnnotationComposer,
          $$LocalAdminProfilesTableCreateCompanionBuilder,
          $$LocalAdminProfilesTableUpdateCompanionBuilder,
          (
            LocalAdminProfile,
            BaseReferences<
              _$AppDatabase,
              $LocalAdminProfilesTable,
              LocalAdminProfile
            >,
          ),
          LocalAdminProfile,
          PrefetchHooks Function()
        > {
  $$LocalAdminProfilesTableTableManager(
    _$AppDatabase db,
    $LocalAdminProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalAdminProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalAdminProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalAdminProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> login = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAdminProfilesCompanion(
                id: id,
                name: name,
                surname: surname,
                email: email,
                login: login,
                institutionId: institutionId,
                phone: phone,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String surname,
                required String email,
                required String login,
                required String institutionId,
                required String phone,
                required DateTime createdAt,
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAdminProfilesCompanion.insert(
                id: id,
                name: name,
                surname: surname,
                email: email,
                login: login,
                institutionId: institutionId,
                phone: phone,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAdminProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAdminProfilesTable,
      LocalAdminProfile,
      $$LocalAdminProfilesTableFilterComposer,
      $$LocalAdminProfilesTableOrderingComposer,
      $$LocalAdminProfilesTableAnnotationComposer,
      $$LocalAdminProfilesTableCreateCompanionBuilder,
      $$LocalAdminProfilesTableUpdateCompanionBuilder,
      (
        LocalAdminProfile,
        BaseReferences<
          _$AppDatabase,
          $LocalAdminProfilesTable,
          LocalAdminProfile
        >,
      ),
      LocalAdminProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalInstitutionsTableCreateCompanionBuilder =
    LocalInstitutionsCompanion Function({
      required String id,
      required String name,
      required String address,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalInstitutionsTableUpdateCompanionBuilder =
    LocalInstitutionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> address,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalInstitutionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInstitutionsTable> {
  $$LocalInstitutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInstitutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInstitutionsTable> {
  $$LocalInstitutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInstitutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInstitutionsTable> {
  $$LocalInstitutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalInstitutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInstitutionsTable,
          LocalInstitution,
          $$LocalInstitutionsTableFilterComposer,
          $$LocalInstitutionsTableOrderingComposer,
          $$LocalInstitutionsTableAnnotationComposer,
          $$LocalInstitutionsTableCreateCompanionBuilder,
          $$LocalInstitutionsTableUpdateCompanionBuilder,
          (
            LocalInstitution,
            BaseReferences<
              _$AppDatabase,
              $LocalInstitutionsTable,
              LocalInstitution
            >,
          ),
          LocalInstitution,
          PrefetchHooks Function()
        > {
  $$LocalInstitutionsTableTableManager(
    _$AppDatabase db,
    $LocalInstitutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalInstitutionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalInstitutionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalInstitutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInstitutionsCompanion(
                id: id,
                name: name,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String address,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInstitutionsCompanion.insert(
                id: id,
                name: name,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInstitutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInstitutionsTable,
      LocalInstitution,
      $$LocalInstitutionsTableFilterComposer,
      $$LocalInstitutionsTableOrderingComposer,
      $$LocalInstitutionsTableAnnotationComposer,
      $$LocalInstitutionsTableCreateCompanionBuilder,
      $$LocalInstitutionsTableUpdateCompanionBuilder,
      (
        LocalInstitution,
        BaseReferences<
          _$AppDatabase,
          $LocalInstitutionsTable,
          LocalInstitution
        >,
      ),
      LocalInstitution,
      PrefetchHooks Function()
    >;
typedef $$LocalLessonsTableCreateCompanionBuilder =
    LocalLessonsCompanion Function({
      required String id,
      required String scheduleId,
      Value<String?> topic,
      Value<String> attendanceStatus,
      Value<int> rowid,
    });
typedef $$LocalLessonsTableUpdateCompanionBuilder =
    LocalLessonsCompanion Function({
      Value<String> id,
      Value<String> scheduleId,
      Value<String?> topic,
      Value<String> attendanceStatus,
      Value<int> rowid,
    });

class $$LocalLessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLessonsTable> {
  $$LocalLessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceStatus => $composableBuilder(
    column: $table.attendanceStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLessonsTable> {
  $$LocalLessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceStatus => $composableBuilder(
    column: $table.attendanceStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLessonsTable> {
  $$LocalLessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get attendanceStatus => $composableBuilder(
    column: $table.attendanceStatus,
    builder: (column) => column,
  );
}

class $$LocalLessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLessonsTable,
          LocalLesson,
          $$LocalLessonsTableFilterComposer,
          $$LocalLessonsTableOrderingComposer,
          $$LocalLessonsTableAnnotationComposer,
          $$LocalLessonsTableCreateCompanionBuilder,
          $$LocalLessonsTableUpdateCompanionBuilder,
          (
            LocalLesson,
            BaseReferences<_$AppDatabase, $LocalLessonsTable, LocalLesson>,
          ),
          LocalLesson,
          PrefetchHooks Function()
        > {
  $$LocalLessonsTableTableManager(_$AppDatabase db, $LocalLessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalLessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalLessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$LocalLessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scheduleId = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String> attendanceStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLessonsCompanion(
                id: id,
                scheduleId: scheduleId,
                topic: topic,
                attendanceStatus: attendanceStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scheduleId,
                Value<String?> topic = const Value.absent(),
                Value<String> attendanceStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLessonsCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                topic: topic,
                attendanceStatus: attendanceStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLessonsTable,
      LocalLesson,
      $$LocalLessonsTableFilterComposer,
      $$LocalLessonsTableOrderingComposer,
      $$LocalLessonsTableAnnotationComposer,
      $$LocalLessonsTableCreateCompanionBuilder,
      $$LocalLessonsTableUpdateCompanionBuilder,
      (
        LocalLesson,
        BaseReferences<_$AppDatabase, $LocalLessonsTable, LocalLesson>,
      ),
      LocalLesson,
      PrefetchHooks Function()
    >;
typedef $$LocalLessonAttendancesTableCreateCompanionBuilder =
    LocalLessonAttendancesCompanion Function({
      Value<String?> id,
      required String lessonId,
      required String studentId,
      Value<String?> status,
      Value<int> rowid,
    });
typedef $$LocalLessonAttendancesTableUpdateCompanionBuilder =
    LocalLessonAttendancesCompanion Function({
      Value<String?> id,
      Value<String> lessonId,
      Value<String> studentId,
      Value<String?> status,
      Value<int> rowid,
    });

class $$LocalLessonAttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLessonAttendancesTable> {
  $$LocalLessonAttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLessonAttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLessonAttendancesTable> {
  $$LocalLessonAttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLessonAttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLessonAttendancesTable> {
  $$LocalLessonAttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$LocalLessonAttendancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLessonAttendancesTable,
          LocalLessonAttendance,
          $$LocalLessonAttendancesTableFilterComposer,
          $$LocalLessonAttendancesTableOrderingComposer,
          $$LocalLessonAttendancesTableAnnotationComposer,
          $$LocalLessonAttendancesTableCreateCompanionBuilder,
          $$LocalLessonAttendancesTableUpdateCompanionBuilder,
          (
            LocalLessonAttendance,
            BaseReferences<
              _$AppDatabase,
              $LocalLessonAttendancesTable,
              LocalLessonAttendance
            >,
          ),
          LocalLessonAttendance,
          PrefetchHooks Function()
        > {
  $$LocalLessonAttendancesTableTableManager(
    _$AppDatabase db,
    $LocalLessonAttendancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalLessonAttendancesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalLessonAttendancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalLessonAttendancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLessonAttendancesCompanion(
                id: id,
                lessonId: lessonId,
                studentId: studentId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                required String lessonId,
                required String studentId,
                Value<String?> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLessonAttendancesCompanion.insert(
                id: id,
                lessonId: lessonId,
                studentId: studentId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLessonAttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLessonAttendancesTable,
      LocalLessonAttendance,
      $$LocalLessonAttendancesTableFilterComposer,
      $$LocalLessonAttendancesTableOrderingComposer,
      $$LocalLessonAttendancesTableAnnotationComposer,
      $$LocalLessonAttendancesTableCreateCompanionBuilder,
      $$LocalLessonAttendancesTableUpdateCompanionBuilder,
      (
        LocalLessonAttendance,
        BaseReferences<
          _$AppDatabase,
          $LocalLessonAttendancesTable,
          LocalLessonAttendance
        >,
      ),
      LocalLessonAttendance,
      PrefetchHooks Function()
    >;
typedef $$LocalChatsTableCreateCompanionBuilder =
    LocalChatsCompanion Function({
      required String id,
      required String type,
      Value<String?> name,
      Value<String?> groupId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalChatsTableUpdateCompanionBuilder =
    LocalChatsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> name,
      Value<String?> groupId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalChatsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatsTable,
          LocalChat,
          $$LocalChatsTableFilterComposer,
          $$LocalChatsTableOrderingComposer,
          $$LocalChatsTableAnnotationComposer,
          $$LocalChatsTableCreateCompanionBuilder,
          $$LocalChatsTableUpdateCompanionBuilder,
          (
            LocalChat,
            BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat>,
          ),
          LocalChat,
          PrefetchHooks Function()
        > {
  $$LocalChatsTableTableManager(_$AppDatabase db, $LocalChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatsCompanion(
                id: id,
                type: type,
                name: name,
                groupId: groupId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> name = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalChatsCompanion.insert(
                id: id,
                type: type,
                name: name,
                groupId: groupId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatsTable,
      LocalChat,
      $$LocalChatsTableFilterComposer,
      $$LocalChatsTableOrderingComposer,
      $$LocalChatsTableAnnotationComposer,
      $$LocalChatsTableCreateCompanionBuilder,
      $$LocalChatsTableUpdateCompanionBuilder,
      (LocalChat, BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat>),
      LocalChat,
      PrefetchHooks Function()
    >;
typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      required String id,
      required String chatId,
      required String senderId,
      required String senderRole,
      Value<String?> content,
      Value<String?> fileUrl,
      Value<String?> fileName,
      Value<bool> isRead,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<String> senderId,
      Value<String> senderRole,
      Value<String?> content,
      Value<String?> fileUrl,
      Value<String?> fileName,
      Value<bool> isRead,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMessagesTable,
          LocalMessage,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (
            LocalMessage,
            BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
          ),
          LocalMessage,
          PrefetchHooks Function()
        > {
  $$LocalMessagesTableTableManager(_$AppDatabase db, $LocalMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> senderRole = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> fileUrl = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                senderRole: senderRole,
                content: content,
                fileUrl: fileUrl,
                fileName: fileName,
                isRead: isRead,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String senderId,
                required String senderRole,
                Value<String?> content = const Value.absent(),
                Value<String?> fileUrl = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                senderRole: senderRole,
                content: content,
                fileUrl: fileUrl,
                fileName: fileName,
                isRead: isRead,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMessagesTable,
      LocalMessage,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (
        LocalMessage,
        BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
      ),
      LocalMessage,
      PrefetchHooks Function()
    >;
typedef $$LocalChatPreviewsTableCreateCompanionBuilder =
    LocalChatPreviewsCompanion Function({
      required String chatId,
      required String userId,
      required String title,
      Value<String?> avatarUrl,
      Value<String?> lastMessage,
      Value<DateTime?> lastMessageTime,
      Value<int> unreadCount,
      required String chatType,
      Value<String?> chatName,
      Value<String?> chatGroupId,
      required DateTime chatUpdatedAt,
      Value<int> rowid,
    });
typedef $$LocalChatPreviewsTableUpdateCompanionBuilder =
    LocalChatPreviewsCompanion Function({
      Value<String> chatId,
      Value<String> userId,
      Value<String> title,
      Value<String?> avatarUrl,
      Value<String?> lastMessage,
      Value<DateTime?> lastMessageTime,
      Value<int> unreadCount,
      Value<String> chatType,
      Value<String?> chatName,
      Value<String?> chatGroupId,
      Value<DateTime> chatUpdatedAt,
      Value<int> rowid,
    });

class $$LocalChatPreviewsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatPreviewsTable> {
  $$LocalChatPreviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatType => $composableBuilder(
    column: $table.chatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatName => $composableBuilder(
    column: $table.chatName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatGroupId => $composableBuilder(
    column: $table.chatGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get chatUpdatedAt => $composableBuilder(
    column: $table.chatUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChatPreviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatPreviewsTable> {
  $$LocalChatPreviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatType => $composableBuilder(
    column: $table.chatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatName => $composableBuilder(
    column: $table.chatName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatGroupId => $composableBuilder(
    column: $table.chatGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get chatUpdatedAt => $composableBuilder(
    column: $table.chatUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatPreviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatPreviewsTable> {
  $$LocalChatPreviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chatType =>
      $composableBuilder(column: $table.chatType, builder: (column) => column);

  GeneratedColumn<String> get chatName =>
      $composableBuilder(column: $table.chatName, builder: (column) => column);

  GeneratedColumn<String> get chatGroupId => $composableBuilder(
    column: $table.chatGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get chatUpdatedAt => $composableBuilder(
    column: $table.chatUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalChatPreviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatPreviewsTable,
          LocalChatPreview,
          $$LocalChatPreviewsTableFilterComposer,
          $$LocalChatPreviewsTableOrderingComposer,
          $$LocalChatPreviewsTableAnnotationComposer,
          $$LocalChatPreviewsTableCreateCompanionBuilder,
          $$LocalChatPreviewsTableUpdateCompanionBuilder,
          (
            LocalChatPreview,
            BaseReferences<
              _$AppDatabase,
              $LocalChatPreviewsTable,
              LocalChatPreview
            >,
          ),
          LocalChatPreview,
          PrefetchHooks Function()
        > {
  $$LocalChatPreviewsTableTableManager(
    _$AppDatabase db,
    $LocalChatPreviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalChatPreviewsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalChatPreviewsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalChatPreviewsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chatId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<DateTime?> lastMessageTime = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String> chatType = const Value.absent(),
                Value<String?> chatName = const Value.absent(),
                Value<String?> chatGroupId = const Value.absent(),
                Value<DateTime> chatUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatPreviewsCompanion(
                chatId: chatId,
                userId: userId,
                title: title,
                avatarUrl: avatarUrl,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount,
                chatType: chatType,
                chatName: chatName,
                chatGroupId: chatGroupId,
                chatUpdatedAt: chatUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chatId,
                required String userId,
                required String title,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<DateTime?> lastMessageTime = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                required String chatType,
                Value<String?> chatName = const Value.absent(),
                Value<String?> chatGroupId = const Value.absent(),
                required DateTime chatUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalChatPreviewsCompanion.insert(
                chatId: chatId,
                userId: userId,
                title: title,
                avatarUrl: avatarUrl,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount,
                chatType: chatType,
                chatName: chatName,
                chatGroupId: chatGroupId,
                chatUpdatedAt: chatUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChatPreviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatPreviewsTable,
      LocalChatPreview,
      $$LocalChatPreviewsTableFilterComposer,
      $$LocalChatPreviewsTableOrderingComposer,
      $$LocalChatPreviewsTableAnnotationComposer,
      $$LocalChatPreviewsTableCreateCompanionBuilder,
      $$LocalChatPreviewsTableUpdateCompanionBuilder,
      (
        LocalChatPreview,
        BaseReferences<
          _$AppDatabase,
          $LocalChatPreviewsTable,
          LocalChatPreview
        >,
      ),
      LocalChatPreview,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalRoomsTableTableManager get localRooms =>
      $$LocalRoomsTableTableManager(_db, _db.localRooms);
  $$LocalSubjectsTableTableManager get localSubjects =>
      $$LocalSubjectsTableTableManager(_db, _db.localSubjects);
  $$LocalGroupsTableTableManager get localGroups =>
      $$LocalGroupsTableTableManager(_db, _db.localGroups);
  $$LocalTeachersTableTableManager get localTeachers =>
      $$LocalTeachersTableTableManager(_db, _db.localTeachers);
  $$LocalSchedulesTableTableManager get localSchedules =>
      $$LocalSchedulesTableTableManager(_db, _db.localSchedules);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalGradesTableTableManager get localGrades =>
      $$LocalGradesTableTableManager(_db, _db.localGrades);
  $$LocalHomeworksTableTableManager get localHomeworks =>
      $$LocalHomeworksTableTableManager(_db, _db.localHomeworks);
  $$LocalHomeworkStatusesTableTableManager get localHomeworkStatuses =>
      $$LocalHomeworkStatusesTableTableManager(_db, _db.localHomeworkStatuses);
  $$LocalStudentsTableTableManager get localStudents =>
      $$LocalStudentsTableTableManager(_db, _db.localStudents);
  $$LocalGroupDetailsTableTableManager get localGroupDetails =>
      $$LocalGroupDetailsTableTableManager(_db, _db.localGroupDetails);
  $$LocalTeacherProfilesTableTableManager get localTeacherProfiles =>
      $$LocalTeacherProfilesTableTableManager(_db, _db.localTeacherProfiles);
  $$LocalAdminProfilesTableTableManager get localAdminProfiles =>
      $$LocalAdminProfilesTableTableManager(_db, _db.localAdminProfiles);
  $$LocalInstitutionsTableTableManager get localInstitutions =>
      $$LocalInstitutionsTableTableManager(_db, _db.localInstitutions);
  $$LocalLessonsTableTableManager get localLessons =>
      $$LocalLessonsTableTableManager(_db, _db.localLessons);
  $$LocalLessonAttendancesTableTableManager get localLessonAttendances =>
      $$LocalLessonAttendancesTableTableManager(
        _db,
        _db.localLessonAttendances,
      );
  $$LocalChatsTableTableManager get localChats =>
      $$LocalChatsTableTableManager(_db, _db.localChats);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
  $$LocalChatPreviewsTableTableManager get localChatPreviews =>
      $$LocalChatPreviewsTableTableManager(_db, _db.localChatPreviews);
}
