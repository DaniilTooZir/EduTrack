import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/utils/app_result.dart';

class SubjectRepository {
  final SubjectService _remote;
  final AppDatabase _local;

  SubjectRepository({required SubjectService remote, required AppDatabase local}) : _remote = remote, _local = local;

  // Cache-first: предметы уже есть в LocalSubjects после загрузки расписания
  // Фоновое обновление не нужно — предметы обновляются при сохранении расписания
  Future<AppResult<List<Subject>>> getSubjectsByTeacherId(String teacherId) async {
    final cached = await _local.getSubjectsByTeacher(teacherId);
    if (cached.isNotEmpty) return AppResult.success(cached);
    return _remote.getSubjectsByTeacherId(teacherId);
  }

  Future<AppResult<List<Subject>>> getSubjectsForInstitution(String institutionId) =>
      _remote.getSubjectsForInstitution(institutionId);

  Future<AppResult<void>> addSubject({required String name, required String institutionId}) =>
      _remote.addSubject(name: name, institutionId: institutionId);

  Future<AppResult<void>> updateSubject({required String id, required String name}) =>
      _remote.updateSubject(id: id, name: name);

  Future<AppResult<void>> deleteSubject(String id) => _remote.deleteSubject(id);
}
