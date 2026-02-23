// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
          ..write('date: $date, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSubjectsTable localSubjects = $LocalSubjectsTable(this);
  late final $LocalGroupsTable localGroups = $LocalGroupsTable(this);
  late final $LocalTeachersTable localTeachers = $LocalTeachersTable(this);
  late final $LocalSchedulesTable localSchedules = $LocalSchedulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localSubjects,
    localGroups,
    localTeachers,
    localSchedules,
  ];
}

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
          PrefetchHooks Function({bool subjectId, bool groupId, bool teacherId})
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
      PrefetchHooks Function({bool subjectId, bool groupId, bool teacherId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSubjectsTableTableManager get localSubjects =>
      $$LocalSubjectsTableTableManager(_db, _db.localSubjects);
  $$LocalGroupsTableTableManager get localGroups =>
      $$LocalGroupsTableTableManager(_db, _db.localGroups);
  $$LocalTeachersTableTableManager get localTeachers =>
      $$LocalTeachersTableTableManager(_db, _db.localTeachers);
  $$LocalSchedulesTableTableManager get localSchedules =>
      $$LocalSchedulesTableTableManager(_db, _db.localSchedules);
}
