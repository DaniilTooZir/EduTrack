import 'package:edu_track/data/repositories/group_repository.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/chat_screen.dart';
import 'package:edu_track/ui/screens/teacher/curator_group_journal_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherMyGroupScreen extends StatefulWidget {
  const TeacherMyGroupScreen({super.key});

  @override
  State<TeacherMyGroupScreen> createState() => _TeacherMyGroupScreenState();
}

class _TeacherMyGroupScreenState extends State<TeacherMyGroupScreen> {
  GroupRepository get _groupRepository => Provider.of<GroupRepository>(context, listen: false);

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
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final groupResult = await _groupRepository.getGroupByCurator(teacherId);
    if (groupResult.isFailure) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _myGroup = groupResult.data;
    if (_myGroup != null && _myGroup!.id != null) {
      final studentsResult = await _groupRepository.getStudentsByGroupId(_myGroup!.id!);
      if (studentsResult.isSuccess) _students = studentsResult.data;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _setHeadman(Student student) async {
    if (_myGroup?.id == null) return;
    final previousStudents = List<Student>.from(_students);
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
    final result = await _groupRepository.setHeadman(_myGroup!.id!, student.id);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() => _students = previousStudents);
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    MessengerHelper.showSuccess('${student.name} назначен(а) старостой');
  }

  Future<void> _confirmSetHeadman(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Назначить старосту?'),
            content: Text('${student.surname} ${student.name} будет назначен(а) старостой группы.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Назначить')),
            ],
          ),
    );
    if (confirmed == true) await _setHeadman(student);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _myGroup == null ? null : _openGroupChat,
        label: const Text('Чат группы'),
        icon: const Icon(Icons.forum),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _isLoading
                  ? _buildMyGroupSkeleton()
                  : _myGroup == null
                  ? RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.supervised_user_circle,
                                  size: 64,
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppSpacing.l),
                                Text(
                                  'Вы не являетесь куратором группы.',
                                  style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(AppSpacing.l),
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
                              color: colors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Группа ${_myGroup!.name}',
                                        style: TextStyle(
                                          color: colors.onPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Студентов: ${_students.length}',
                                        style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.9), fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.supervised_user_circle_rounded,
                                  size: 48,
                                  color: colors.onPrimary.withValues(alpha: 0.25),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.l),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CuratorGroupJournalScreen(
                                              groupId: _myGroup!.id!,
                                              groupName: _myGroup!.name,
                                              students: _students,
                                            ),
                                      ),
                                    ),
                                icon: const Icon(Icons.assessment_rounded, color: Colors.white),
                                label: const Text(
                                  'Журнал успеваемости группы',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white54),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.message_outlined, color: colors.primary),
                                        tooltip: 'Написать сообщение',
                                        onPressed: () => _openDirectChat(student),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.workspace_premium_rounded,
                                          color: student.isHeadman ? Colors.amber : colors.onSurfaceVariant,
                                        ),
                                        tooltip: student.isHeadman ? 'Уже является старостой' : 'Назначить старостой',
                                        onPressed: student.isHeadman ? null : () => _confirmSetHeadman(student),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Future<void> _openGroupChat() async {
    if (_myGroup == null) return;
    final result = await ChatService().getOrCreateGroupChat(_myGroup!.id!, _myGroup!.name);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: result.data, title: 'Группа ${_myGroup!.name}')));
  }

  Future<void> _openDirectChat(Student student) async {
    final myId = Provider.of<UserProvider>(context, listen: false).userId;
    if (myId == null) return;
    final result = await ChatService().getOrCreateDirectChat(
      myId: myId,
      myRole: 'teacher',
      otherId: student.id,
      otherRole: 'student',
    );
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chatId: result.data, title: '${student.surname} ${student.name}')),
    );
  }

  Widget _buildMyGroupSkeleton() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(AppSpacing.l),
          child: Skeleton(height: 120, width: double.infinity, borderRadius: 16),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            itemBuilder:
                (context, index) => const ListTile(
                  leading: Skeleton(height: 40, width: 40, borderRadius: 20),
                  title: Skeleton(height: 14, width: 140),
                  subtitle: Skeleton(height: 10, width: 180),
                  trailing: Skeleton(height: 24, width: 40),
                ),
          ),
        ),
      ],
    );
  }
}
