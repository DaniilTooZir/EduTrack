import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';


class LocalSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get institutionId => text()();
  TextColumn get subjectId => text().references(LocalSubjects, #id)();
  TextColumn get groupId => text().references(LocalGroups, #id)();
  TextColumn get teacherId => text().references(LocalTeachers, #id)();
  DateTimeColumn get date => dateTime().nullable()();
  IntColumn get weekday => integer()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSubjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get institutionId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get institutionId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalTeachers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalSchedules, LocalSubjects, LocalGroups, LocalTeachers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  Future<void> clearAll() async {
    await delete(localSchedules).go();
    await delete(localSubjects).go();
    await delete(localGroups).go();
    await delete(localTeachers).go();
  }
  Future<void> saveSchedules(List<Schedule> schedules) async {
    await transaction(() async {
      for (var s in schedules) {
        if (s.subject != null) {
          await into(localSubjects).insertOnConflictUpdate(LocalSubjectsCompanion.insert(
            id: s.subject!.id,
            name: s.subject!.name,
            institutionId: s.subject!.institutionId,
          ));
        }

        if (s.group != null && s.group!.id != null) {
          await into(localGroups).insertOnConflictUpdate(LocalGroupsCompanion.insert(
            id: s.group!.id!,
            name: s.group!.name,
            institutionId: s.group!.institutionId,
          ));
        }

        if (s.teacher != null) {
          await into(localTeachers).insertOnConflictUpdate(LocalTeachersCompanion.insert(
            id: s.teacher!.id,
            name: s.teacher!.name,
            surname: s.teacher!.surname,
          ));
        }

        await into(localSchedules).insertOnConflictUpdate(LocalSchedulesCompanion.insert(
          id: s.id,
          institutionId: s.institutionId,
          subjectId: s.subjectId,
          groupId: s.groupId,
          teacherId: s.teacherId,
          weekday: s.weekday,
          startTime: s.startTime,
          endTime: s.endTime,
          date: Value(s.date),
        ));
      }
    });
  }

  Future<List<Schedule>> getSchedulesForGroup(String groupId) async {
    final query = select(localSchedules).join([
      leftOuterJoin(localSubjects, localSubjects.id.equalsExp(localSchedules.subjectId)),
      leftOuterJoin(localGroups, localGroups.id.equalsExp(localSchedules.groupId)),
      leftOuterJoin(localTeachers, localTeachers.id.equalsExp(localSchedules.teacherId)),
    ]);
    query.where(localSchedules.groupId.equals(groupId));
    query.orderBy([
      OrderingTerm(expression: localSchedules.date),
      OrderingTerm(expression: localSchedules.startTime),
    ]);
    final rows = await query.get();
    return rows.map((row) {
      final scheduleRow = row.readTable(localSchedules);
      final subjectRow = row.readTableOrNull(localSubjects);
      final groupRow = row.readTableOrNull(localGroups);
      final teacherRow = row.readTableOrNull(localTeachers);

      return Schedule(
        id: scheduleRow.id,
        institutionId: scheduleRow.institutionId,
        subjectId: scheduleRow.subjectId,
        groupId: scheduleRow.groupId,
        teacherId: scheduleRow.teacherId,
        weekday: scheduleRow.weekday,
        startTime: scheduleRow.startTime,
        endTime: scheduleRow.endTime,
        date: scheduleRow.date,
        subject: subjectRow != null
            ? Subject(
          id: subjectRow.id,
          name: subjectRow.name,
          institutionId: subjectRow.institutionId,
          createdAt: DateTime.now(),
        )
            : null,
        group: groupRow != null
            ? Group(
          id: groupRow.id,
          name: groupRow.name,
          institutionId: groupRow.institutionId,
        )
            : null,
        teacher: teacherRow != null
            ? Teacher(
            id: teacherRow.id,
            name: teacherRow.name,
            surname: teacherRow.surname,
            email: '', login: '', password: '', institutionId: '', createdAt: DateTime.now()
        )
            : null,
      );
    }).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}