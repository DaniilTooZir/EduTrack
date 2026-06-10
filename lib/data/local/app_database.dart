import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:edu_track/data/services/auth_service.dart';
import 'package:edu_track/models/education_head.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/models/institution.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/room.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LocalRooms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get institutionId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get institutionId => text()();
  TextColumn get subjectId => text().references(LocalSubjects, #id)();
  TextColumn get groupId => text().references(LocalGroups, #id)();
  TextColumn get teacherId => text().references(LocalTeachers, #id)();
  TextColumn get roomId => text().nullable().references(LocalRooms, #id)();
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

// Полные профили студентов (для экрана профиля и списка группы)
class LocalStudents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get email => text()();
  TextColumn get login => text()();
  TextColumn get groupId => text().nullable()();
  BoolColumn get isHeadman => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get avatarUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Полные данные группы (включая curatorId — нужен для поиска группы куратора)
class LocalGroupDetails extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get institutionId => text()();
  TextColumn get curatorId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Полные профили преподавателей (для экрана профиля преподавателя)
class LocalTeacherProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get email => text()();
  TextColumn get login => text()();
  TextColumn get institutionId => text()();
  TextColumn get department => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get avatarUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Полные профили администраторов (для экрана профиля)
class LocalAdminProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get email => text()();
  TextColumn get login => text()();
  TextColumn get institutionId => text()();
  TextColumn get phone => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get avatarUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Учреждения (для экранов профиля)
class LocalInstitutions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalLessons extends Table {
  TextColumn get id => text()();
  TextColumn get scheduleId => text()();
  TextColumn get topic => text().nullable()();
  TextColumn get attendanceStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalRooms,
    LocalSchedules,
    LocalSubjects,
    LocalGroups,
    LocalTeachers,
    LocalUsers,
    LocalGrades,
    LocalHomeworks,
    LocalHomeworkStatuses,
    LocalStudents,
    LocalGroupDetails,
    LocalTeacherProfiles,
    LocalAdminProfiles,
    LocalInstitutions,
    LocalLessons,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

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
    await delete(localRooms).go();
    await delete(localSubjects).go();
    await delete(localGroups).go();
    await delete(localTeachers).go();
    await delete(localUsers).go();
    await delete(localGrades).go();
    await delete(localHomeworks).go();
    await delete(localHomeworkStatuses).go();
    await delete(localStudents).go();
    await delete(localGroupDetails).go();
    await delete(localTeacherProfiles).go();
    await delete(localAdminProfiles).go();
    await delete(localInstitutions).go();
    await delete(localLessons).go();
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
        if (s.room != null) {
          await into(localRooms).insertOnConflictUpdate(
            LocalRoomsCompanion.insert(id: s.room!.id, name: s.room!.name, institutionId: s.room!.institutionId),
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
            roomId: Value(s.roomId),
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
      leftOuterJoin(localRooms, localRooms.id.equalsExp(localSchedules.roomId)),
    ]);
    query.where(localSchedules.groupId.equals(groupId));
    query.orderBy([OrderingTerm(expression: localSchedules.date), OrderingTerm(expression: localSchedules.startTime)]);
    final rows = await query.get();
    return rows.map((row) {
      final scheduleRow = row.readTable(localSchedules);
      final subjectRow = row.readTableOrNull(localSubjects);
      final groupRow = row.readTableOrNull(localGroups);
      final teacherRow = row.readTableOrNull(localTeachers);
      final roomRow = row.readTableOrNull(localRooms);
      return Schedule(
        id: scheduleRow.id,
        institutionId: scheduleRow.institutionId,
        subjectId: scheduleRow.subjectId,
        groupId: scheduleRow.groupId,
        teacherId: scheduleRow.teacherId,
        roomId: scheduleRow.roomId,
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
        room: roomRow != null ? Room(id: roomRow.id, name: roomRow.name, institutionId: roomRow.institutionId) : null,
      );
    }).toList();
  }

  Future<List<Schedule>> getSchedulesForTeacher(String teacherId) async {
    final query = select(localSchedules).join([
      leftOuterJoin(localSubjects, localSubjects.id.equalsExp(localSchedules.subjectId)),
      leftOuterJoin(localGroups, localGroups.id.equalsExp(localSchedules.groupId)),
      leftOuterJoin(localRooms, localRooms.id.equalsExp(localSchedules.roomId)),
    ]);
    query.where(localSchedules.teacherId.equals(teacherId));
    query.orderBy([OrderingTerm(expression: localSchedules.date), OrderingTerm(expression: localSchedules.startTime)]);
    final rows = await query.get();
    return rows.map((row) {
      final scheduleRow = row.readTable(localSchedules);
      final subjectRow = row.readTableOrNull(localSubjects);
      final groupRow = row.readTableOrNull(localGroups);
      final roomRow = row.readTableOrNull(localRooms);
      return Schedule(
        id: scheduleRow.id,
        institutionId: scheduleRow.institutionId,
        subjectId: scheduleRow.subjectId,
        groupId: scheduleRow.groupId,
        teacherId: scheduleRow.teacherId,
        roomId: scheduleRow.roomId,
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
        room: roomRow != null ? Room(id: roomRow.id, name: roomRow.name, institutionId: roomRow.institutionId) : null,
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

  Future<void> saveGrade(Grade grade) async {
    if (grade.id == null) return;
    await into(localGrades).insertOnConflictUpdate(
      LocalGradesCompanion.insert(
        id: grade.id!,
        lessonId: grade.lessonId,
        studentId: grade.studentId,
        value: grade.value,
      ),
    );
  }

  Future<void> deleteGradeByLessonAndStudent(String lessonId, String studentId) async {
    await (delete(localGrades)..where((t) => t.lessonId.equals(lessonId) & t.studentId.equals(studentId))).go();
  }

  Future<void> saveLessonsData(List<Lesson> lessons) async {
    await transaction(() async {
      for (final l in lessons) {
        if (l.id == null || l.id!.isEmpty) continue;
        await into(localLessons).insertOnConflictUpdate(
          LocalLessonsCompanion.insert(
            id: l.id!,
            scheduleId: l.scheduleId,
            topic: Value(l.topic),
            attendanceStatus: Value(l.attendanceStatus),
          ),
        );
      }
    });
  }

  Future<List<Lesson>> getLessonsCachedByScheduleIds(List<String> scheduleIds) async {
    if (scheduleIds.isEmpty) return [];
    final rows = await (select(localLessons)..where((t) => t.scheduleId.isIn(scheduleIds))).get();
    return rows
        .map((r) => Lesson(id: r.id, scheduleId: r.scheduleId, topic: r.topic, attendanceStatus: r.attendanceStatus))
        .toList();
  }

  Future<void> deleteLessonsForSchedules(List<String> scheduleIds) async {
    if (scheduleIds.isEmpty) return;
    await (delete(localLessons)..where((t) => t.scheduleId.isIn(scheduleIds))).go();
  }

  Future<void> saveLessons(Map<String, String> lessonIdToScheduleId) async {
    await transaction(() async {
      for (final e in lessonIdToScheduleId.entries) {
        await into(localLessons).insertOnConflictUpdate(LocalLessonsCompanion.insert(id: e.key, scheduleId: e.value));
      }
    });
  }

  Future<Map<String, String>> getLessonScheduleMap(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return {};
    final rows = await (select(localLessons)..where((t) => t.id.isIn(lessonIds))).get();
    return {for (final r in rows) r.id: r.scheduleId};
  }

  Future<Map<String, ({String subjectId, DateTime? date})>> getScheduleSubjectDateMap(List<String> scheduleIds) async {
    if (scheduleIds.isEmpty) return {};
    final rows = await (select(localSchedules)..where((t) => t.id.isIn(scheduleIds))).get();
    return {for (final r in rows) r.id: (subjectId: r.subjectId, date: r.date)};
  }

  Future<Map<String, Subject>> getSubjectsByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(localSubjects)..where((t) => t.id.isIn(ids))).get();
    return {
      for (final r in rows)
        r.id: Subject(id: r.id, name: r.name, institutionId: r.institutionId, createdAt: DateTime.now()),
    };
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

  Future<void> patchHomeworkStatusByKey({
    required String homeworkId,
    required String studentId,
    bool? isCompleted,
    Value<String?> studentComment = const Value.absent(),
    Value<String?> teacherComment = const Value.absent(),
    Value<String?> fileUrl = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
  }) async {
    await (update(localHomeworkStatuses)
      ..where((t) => t.homeworkId.equals(homeworkId) & t.studentId.equals(studentId))).write(
      LocalHomeworkStatusesCompanion(
        isCompleted: isCompleted != null ? Value(isCompleted) : const Value.absent(),
        studentComment: studentComment,
        teacherComment: teacherComment,
        fileUrl: fileUrl,
        fileName: fileName,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteHomeworkFromCache(String id) async {
    await (delete(localHomeworks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> saveStudents(List<Student> students) async {
    await transaction(() async {
      for (final s in students) {
        await into(localStudents).insertOnConflictUpdate(
          LocalStudentsCompanion.insert(
            id: s.id,
            name: s.name,
            surname: s.surname,
            email: s.email,
            login: s.login,
            groupId: Value(s.groupId),
            isHeadman: Value(s.isHeadman),
            createdAt: s.createdAt,
            avatarUrl: Value(s.avatarUrl),
          ),
        );
      }
    });
  }

  Future<void> saveStudent(Student student) => saveStudents([student]);

  Future<Student?> getStudentById(String id) async {
    final row = await (select(localStudents)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToStudent(row);
  }

  Future<List<Student>> getStudentsByGroupId(String groupId) async {
    final rows =
        await (select(localStudents)
              ..where((t) => t.groupId.equals(groupId))
              ..orderBy([(t) => OrderingTerm(expression: t.surname)]))
            .get();
    return rows.map(_rowToStudent).toList();
  }

  Student _rowToStudent(LocalStudent row) => Student(
    id: row.id,
    name: row.name,
    surname: row.surname,
    email: row.email,
    login: row.login,
    password: '',
    groupId: row.groupId,
    isHeadman: row.isHeadman,
    createdAt: row.createdAt,
    avatarUrl: row.avatarUrl,
  );

  Future<void> saveGroupDetail(Group group) async {
    if (group.id == null) return;
    await into(localGroupDetails).insertOnConflictUpdate(
      LocalGroupDetailsCompanion.insert(
        id: group.id!,
        name: group.name,
        institutionId: group.institutionId,
        curatorId: Value(group.curatorId),
        createdAt: Value(group.createdAt),
      ),
    );
  }

  Future<Group?> getGroupByCuratorId(String curatorId) async {
    final row = await (select(localGroupDetails)..where((t) => t.curatorId.equals(curatorId))).getSingleOrNull();
    if (row == null) return null;
    return Group(
      id: row.id,
      name: row.name,
      institutionId: row.institutionId,
      curatorId: row.curatorId,
      createdAt: row.createdAt,
    );
  }

  Future<void> saveTeacherProfile(Teacher teacher) async {
    await into(localTeacherProfiles).insertOnConflictUpdate(
      LocalTeacherProfilesCompanion.insert(
        id: teacher.id,
        name: teacher.name,
        surname: teacher.surname,
        email: teacher.email,
        login: teacher.login,
        institutionId: teacher.institutionId,
        department: Value(teacher.department),
        createdAt: teacher.createdAt,
        avatarUrl: Value(teacher.avatarUrl),
      ),
    );
  }

  Future<Teacher?> getTeacherProfileById(String id) async {
    final row = await (select(localTeacherProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Teacher(
      id: row.id,
      name: row.name,
      surname: row.surname,
      email: row.email,
      login: row.login,
      password: '',
      institutionId: row.institutionId,
      department: row.department,
      createdAt: row.createdAt,
      avatarUrl: row.avatarUrl,
    );
  }

  Future<void> saveAdminProfile(EducationHead admin) async {
    await into(localAdminProfiles).insertOnConflictUpdate(
      LocalAdminProfilesCompanion.insert(
        id: admin.id,
        name: admin.name,
        surname: admin.surname,
        email: admin.email,
        login: admin.login,
        institutionId: admin.institutionId,
        phone: admin.phone,
        createdAt: admin.createdAt,
        avatarUrl: Value(admin.avatarUrl),
      ),
    );
  }

  Future<EducationHead?> getAdminProfileById(String id) async {
    final row = await (select(localAdminProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return EducationHead(
      id: row.id,
      name: row.name,
      surname: row.surname,
      email: row.email,
      login: row.login,
      password: '',
      institutionId: row.institutionId,
      phone: row.phone,
      createdAt: row.createdAt,
      avatarUrl: row.avatarUrl,
    );
  }

  Future<void> saveInstitution(Institution institution) async {
    await into(localInstitutions).insertOnConflictUpdate(
      LocalInstitutionsCompanion.insert(
        id: institution.id,
        name: institution.name,
        address: institution.address,
        createdAt: institution.createdAt,
      ),
    );
  }

  Future<Institution?> getInstitutionById(String id) async {
    final row = await (select(localInstitutions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Institution(id: row.id, name: row.name, address: row.address, createdAt: row.createdAt);
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
