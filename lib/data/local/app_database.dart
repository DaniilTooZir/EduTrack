import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:edu_track/data/services/auth_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
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

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get name => text().nullable()();
  TextColumn get surname => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get login => text().nullable()();
  TextColumn get institutionId => text()();
  TextColumn get groupId => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get institutionName => text().nullable()();
  TextColumn get groupName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalGrades extends Table {
  TextColumn get id => text()();
  TextColumn get lessonId => text()();
  TextColumn get studentId => text()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHomeworks extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get groupId => text()();
  TextColumn get lessonId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get fileUrl => text().nullable()();
  TextColumn get fileName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHomeworkStatuses extends Table {
  TextColumn get id => text()();
  TextColumn get homeworkId => text()();
  TextColumn get studentId => text()();
  BoolColumn get isCompleted => boolean()();
  TextColumn get studentComment => text().nullable()();
  TextColumn get teacherComment => text().nullable()();
  TextColumn get fileUrl => text().nullable()();
  TextColumn get fileName => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalSchedules,
    LocalSubjects,
    LocalGroups,
    LocalTeachers,
    LocalUsers,
    LocalGrades,
    LocalHomeworks,
    LocalHomeworkStatuses,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      for (final table in allTables) {
        await m.drop(table);
      }
      await m.createAll();
    },
  );

  Future<void> clearAll() async {
    await delete(localSchedules).go();
    await delete(localSubjects).go();
    await delete(localGroups).go();
    await delete(localTeachers).go();
    await delete(localUsers).go();
    await delete(localGrades).go();
    await delete(localHomeworks).go();
    await delete(localHomeworkStatuses).go();
  }

  Future<void> saveSchedules(List<Schedule> schedules) async {
    await transaction(() async {
      for (final s in schedules) {
        if (s.subject != null) {
          await into(localSubjects).insertOnConflictUpdate(
            LocalSubjectsCompanion.insert(
              id: s.subject!.id,
              name: s.subject!.name,
              institutionId: s.subject!.institutionId,
            ),
          );
        }
        if (s.group != null && s.group!.id != null) {
          await into(localGroups).insertOnConflictUpdate(
            LocalGroupsCompanion.insert(id: s.group!.id!, name: s.group!.name, institutionId: s.group!.institutionId),
          );
        }
        if (s.teacher != null) {
          await into(localTeachers).insertOnConflictUpdate(
            LocalTeachersCompanion.insert(id: s.teacher!.id, name: s.teacher!.name, surname: s.teacher!.surname),
          );
        }
        await into(localSchedules).insertOnConflictUpdate(
          LocalSchedulesCompanion.insert(
            id: s.id,
            institutionId: s.institutionId,
            subjectId: s.subjectId,
            groupId: s.groupId,
            teacherId: s.teacherId,
            weekday: s.weekday,
            startTime: s.startTime,
            endTime: s.endTime,
            date: Value(s.date),
          ),
        );
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
    query.orderBy([OrderingTerm(expression: localSchedules.date), OrderingTerm(expression: localSchedules.startTime)]);
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
        subject:
            subjectRow != null
                ? Subject(
                  id: subjectRow.id,
                  name: subjectRow.name,
                  institutionId: subjectRow.institutionId,
                  createdAt: DateTime.now(),
                )
                : null,
        group:
            groupRow != null
                ? Group(id: groupRow.id, name: groupRow.name, institutionId: groupRow.institutionId)
                : null,
        teacher:
            teacherRow != null
                ? Teacher(
                  id: teacherRow.id,
                  name: teacherRow.name,
                  surname: teacherRow.surname,
                  email: '',
                  login: '',
                  password: '',
                  institutionId: '',
                  createdAt: DateTime.now(),
                )
                : null,
      );
    }).toList();
  }

  Future<List<Schedule>> getSchedulesForTeacher(String teacherId) async {
    final query = select(localSchedules).join([
      leftOuterJoin(localSubjects, localSubjects.id.equalsExp(localSchedules.subjectId)),
      leftOuterJoin(localGroups, localGroups.id.equalsExp(localSchedules.groupId)),
    ]);
    query.where(localSchedules.teacherId.equals(teacherId));
    query.orderBy([OrderingTerm(expression: localSchedules.date), OrderingTerm(expression: localSchedules.startTime)]);
    final rows = await query.get();
    return rows.map((row) {
      final scheduleRow = row.readTable(localSchedules);
      final subjectRow = row.readTableOrNull(localSubjects);
      final groupRow = row.readTableOrNull(localGroups);
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
        subject:
            subjectRow != null
                ? Subject(
                  id: subjectRow.id,
                  name: subjectRow.name,
                  institutionId: subjectRow.institutionId,
                  createdAt: DateTime.now(),
                )
                : null,
        group:
            groupRow != null
                ? Group(id: groupRow.id, name: groupRow.name, institutionId: groupRow.institutionId)
                : null,
      );
    }).toList();
  }

  Future<void> saveUserProfile(AuthResult auth) async {
    await transaction(() async {
      await delete(localUsers).go();
      await into(localUsers).insert(
        LocalUsersCompanion.insert(
          id: auth.userId,
          role: auth.role,
          name: Value(auth.name),
          surname: Value(auth.surname),
          email: Value(auth.email),
          login: const Value(null),
          institutionId: auth.institutionId,
          groupId: Value(auth.groupId),
          avatarUrl: Value(auth.avatarUrl),
          institutionName: Value(auth.institutionName),
          groupName: Value(auth.groupName),
        ),
      );
    });
  }

  Future<AuthResult?> getUserProfile() async {
    final row = await (select(localUsers)..limit(1)).getSingleOrNull();
    if (row == null) return null;
    return AuthResult(
      role: row.role,
      userId: row.id,
      institutionId: row.institutionId,
      groupId: row.groupId,
      name: row.name,
      surname: row.surname,
      email: row.email,
      avatarUrl: row.avatarUrl,
      institutionName: row.institutionName,
      groupName: row.groupName,
    );
  }

  Future<void> saveGrades(List<Grade> grades) async {
    await transaction(() async {
      for (final grade in grades) {
        if (grade.id == null) continue;
        await into(localGrades).insertOnConflictUpdate(
          LocalGradesCompanion.insert(
            id: grade.id!,
            lessonId: grade.lessonId,
            studentId: grade.studentId,
            value: grade.value,
          ),
        );
      }
    });
  }

  Future<List<Grade>> getGradesByStudent(String studentId) async {
    final rows = await (select(localGrades)..where((t) => t.studentId.equals(studentId))).get();
    return rows.map((r) => Grade(id: r.id, lessonId: r.lessonId, studentId: r.studentId, value: r.value)).toList();
  }

  Future<List<Grade>> getGradesByLesson(String lessonId) async {
    final rows = await (select(localGrades)..where((t) => t.lessonId.equals(lessonId))).get();
    return rows.map((r) => Grade(id: r.id, lessonId: r.lessonId, studentId: r.studentId, value: r.value)).toList();
  }

  Future<void> saveHomeworks(List<Homework> homeworks) async {
    await transaction(() async {
      for (final h in homeworks) {
        if (h.id.isEmpty) continue;
        await into(localHomeworks).insertOnConflictUpdate(
          LocalHomeworksCompanion.insert(
            id: h.id,
            subjectId: h.subjectId,
            groupId: h.groupId,
            lessonId: Value(h.lessonId),
            title: h.title,
            description: Value(h.description),
            dueDate: Value(h.dueDate),
            createdAt: Value(h.createdAt),
            fileUrl: Value(h.fileUrl),
            fileName: Value(h.fileName),
          ),
        );
      }
    });
  }

  Future<List<Homework>> getHomeworksByGroup(String groupId) async {
    final rows =
        await (select(localHomeworks)
              ..where((t) => t.groupId.equals(groupId))
              ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
            .get();
    return rows
        .map(
          (r) => Homework(
            id: r.id,
            subjectId: r.subjectId,
            groupId: r.groupId,
            lessonId: r.lessonId,
            title: r.title,
            description: r.description,
            dueDate: r.dueDate,
            createdAt: r.createdAt,
            fileUrl: r.fileUrl,
            fileName: r.fileName,
          ),
        )
        .toList();
  }

  Future<void> saveHomeworkStatuses(List<HomeworkStatus> statuses) async {
    await transaction(() async {
      for (final s in statuses) {
        if (s.id.isEmpty) continue;
        await into(localHomeworkStatuses).insertOnConflictUpdate(
          LocalHomeworkStatusesCompanion.insert(
            id: s.id,
            homeworkId: s.homeworkId,
            studentId: s.studentId,
            isCompleted: s.isCompleted,
            studentComment: Value(s.studentComment),
            teacherComment: Value(s.teacherComment),
            fileUrl: Value(s.fileUrl),
            fileName: Value(s.fileName),
            updatedAt: s.updatedAt,
          ),
        );
      }
    });
  }

  Future<List<HomeworkStatus>> getHomeworkStatusesByStudent(String studentId) async {
    final rows = await (select(localHomeworkStatuses)..where((t) => t.studentId.equals(studentId))).get();
    return rows
        .map(
          (r) => HomeworkStatus(
            id: r.id,
            homeworkId: r.homeworkId,
            studentId: r.studentId,
            isCompleted: r.isCompleted,
            studentComment: r.studentComment,
            teacherComment: r.teacherComment,
            fileUrl: r.fileUrl,
            fileName: r.fileName,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<List<Subject>> getSubjectsByTeacher(String teacherId) async {
    final query = select(
      localSchedules,
    ).join([innerJoin(localSubjects, localSubjects.id.equalsExp(localSchedules.subjectId))]);
    query.where(localSchedules.teacherId.equals(teacherId));
    final rows = await query.get();
    final seen = <String>{};
    final result = <Subject>[];
    for (final row in rows) {
      final subjectRow = row.readTable(localSubjects);
      if (seen.add(subjectRow.id)) {
        result.add(
          Subject(
            id: subjectRow.id,
            name: subjectRow.name,
            institutionId: subjectRow.institutionId,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
