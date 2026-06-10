import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/data_loading_mixin.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SubjectAdminScreen extends StatefulWidget {
  const SubjectAdminScreen({super.key});

  @override
  State<SubjectAdminScreen> createState() => _SubjectAdminScreenState();
}

class _SubjectAdminScreenState extends State<SubjectAdminScreen> with DataLoadingMixin {
  late final SubjectService _subjectService;
  List<Subject> _subjects = [];
  bool _isAdding = false;
  String? _institutionId;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _subjectNameAllowList = RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9\s\-\.\(\)]');

  List<Subject> get _filteredSubjects {
    if (_searchQuery.isEmpty) return _subjects;
    final q = _searchQuery.toLowerCase();
    return _subjects.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _subjectService = SubjectService();
    _institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_institutionId == null) return;
    await loadAsync(_subjectService.getSubjectsForInstitution(_institutionId!), onSuccess: (data) => _subjects = data);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null) return;
    setState(() => _isAdding = true);
    final result = await _subjectService.addSubject(name: _nameController.text.trim(), institutionId: _institutionId!);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      if (mounted) setState(() => _isAdding = false);
      return;
    }
    MessengerHelper.showSuccess('Предмет успешно добавлен');
    _nameController.clear();
    if (!mounted) return;
    setState(() {
      _isAdding = false;
      _autovalidateMode = AutovalidateMode.disabled;
    });
    await _loadData();
  }

  Future<void> _editSubject(Subject subject) async {
    final editNameController = TextEditingController(text: subject.name);
    final editFormKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text('Изменить предмет'),
                content: Form(
                  key: editFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    controller: editNameController,
                    decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                    inputFormatters: [FilteringTextInputFormatter.allow(_subjectNameAllowList)],
                    validator: (val) => Validators.requiredField(val, fieldName: 'Название'),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                  ElevatedButton(
                    onPressed: () async {
                      if (!editFormKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      setState(() => isLoading = true);
                      final result = await _subjectService.updateSubject(
                        id: subject.id,
                        name: editNameController.text.trim(),
                      );
                      if (result.isFailure) {
                        MessengerHelper.showError(result.errorMessage);
                        if (mounted) setState(() => isLoading = false);
                        return;
                      }
                      MessengerHelper.showSuccess('Предмет обновлён');
                      if (!mounted) return;
                      await _loadData();
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          ),
    );
    editNameController.dispose();
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить предмет?'),
            content: Text(
              'Вы уверены, что хотите удалить предмет "${subject.name}"? Это может затронуть расписание и оценки.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      final result = await _subjectService.deleteSubject(subject.id);
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        if (mounted) setState(() => isLoading = false);
        return;
      }
      MessengerHelper.showSuccess('Предмет удалён');
      if (!mounted) return;
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Название предмета',
                              border: const OutlineInputBorder(),
                              prefixIcon: Icon(Icons.book, color: colors.primary),
                            ),
                            inputFormatters: [FilteringTextInputFormatter.allow(_subjectNameAllowList)],
                            validator: (val) => Validators.requiredField(val, fieldName: 'Название'),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                              ),
                              onPressed: _isAdding ? null : _addSubject,
                              child:
                                  _isAdding
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                                      )
                                      : const Text('Добавить предмет'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Список предметов',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colors.primary),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Поиск предмета',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child:
                        isLoading
                            ? _buildListSkeleton()
                            : _filteredSubjects.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text(
                                      'Список предметов пуст',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredSubjects.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final subject = _filteredSubjects[index];
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: colors.primaryContainer,
                                      child: Text(
                                        subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                                        style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      subject.name,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _editSubject(subject);
                                        if (value == 'delete') _deleteSubject(subject);
                                      },
                                      itemBuilder:
                                          (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color: Colors.blue),
                                                  SizedBox(width: 8),
                                                  Text('Изменить'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Удалить'),
                                                ],
                                              ),
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
      ),
    );
  }

  Widget _buildListSkeleton() {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder:
          (_, __) => Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Skeleton(height: 40, width: 40, borderRadius: 20),
                  const SizedBox(width: AppSpacing.l),
                  const Expanded(child: Skeleton(height: 14)),
                ],
              ),
            ),
          ),
    );
  }
}
