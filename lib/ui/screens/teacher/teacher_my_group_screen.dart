import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherMyGroupScreen extends StatefulWidget {
  const TeacherMyGroupScreen({super.key});

  @override
  State<TeacherMyGroupScreen> createState() => _TeacherMyGroupScreenState();
}

class _TeacherMyGroupScreenState extends State<TeacherMyGroupScreen> {
  final _groupService = GroupService();
  final _studentService = StudentService();

  bool _isLoading = true;
  Group? _myGroup;
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
      if (teacherId == null) return;
      final group = await _groupService.getGroupByCurator(teacherId);
      _myGroup = group;
      if (group != null && group.id != null) {
        final students = await _studentService.getStudentsByGroupId(group.id!);
        _students = students;
      }
    } catch (e) {
      debugPrint('Ошибка загрузки моей группы: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setHeadman(Student student) async {
    if (_myGroup?.id == null) return;
    final previousStudents = List<Student>.from(_students); // Бэкап
    setState(() {
      _students =
          _students.map((s) {
            return Student(
              id: s.id,
              name: s.name,
              surname: s.surname,
              email: s.email,
              login: s.login,
              password: s.password,
              groupId: s.groupId,
              isHeadman: s.id == student.id,
              createdAt: s.createdAt,
              group: s.group,
              avatarUrl: s.avatarUrl,
            );
          }).toList();
    });
    try {
      await _studentService.setHeadman(_myGroup!.id!, student.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${student.name} назначен(а) старостой')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _students = previousStudents);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Кураторство')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myGroup == null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.supervised_user_circle, size: 64, color: colors.onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Вы не являетесь куратором группы.',
                          style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Группа ${_myGroup!.name}',
                              style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Студентов: ${_students.length}',
                              style: TextStyle(color: colors.onPrimary.withOpacity(0.9), fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _students.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              color: colors.surface,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: student.isHeadman ? Colors.amber : colors.primaryContainer,
                                  child: Icon(
                                    student.isHeadman ? Icons.star : Icons.person,
                                    color: student.isHeadman ? Colors.white : colors.onPrimaryContainer,
                                  ),
                                ),
                                title: Text(
                                  '${student.surname} ${student.name}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
                                ),
                                subtitle: Text(
                                  student.email,
                                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                                ),
                                trailing: Tooltip(
                                  message: 'Назначить старостой',
                                  child: Switch(
                                    value: student.isHeadman,
                                    activeColor: Colors.amber,
                                    onChanged: (value) {
                                      if (value) {
                                        _setHeadman(student);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
