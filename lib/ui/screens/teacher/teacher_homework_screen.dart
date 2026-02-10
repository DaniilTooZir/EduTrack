import 'package:edu_track/data/services/file_service.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  final Function(int)? onTabRequest;
  const TeacherHomeworkScreen({super.key, this.onTabRequest});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeworkService = HomeworkService();
  final _subjectService = SubjectService();
  final _groupService = GroupService();
  final _fileService = FileService();
  PlatformFile? _selectedFile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingFile = false;
  List<Homework> _homeworks = [];
  List<Subject> _subjects = [];
  List<Group> _groups = [];
  String? _selectedSubjectId;
  String? _selectedGroupId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId!;
      final institutionId = userProvider.institutionId!;
      final subjects = await _subjectService.getSubjectsByTeacherId(userId);
      final groups = await _groupService.getGroups(institutionId);
      final homeworks = await _homeworkService.getHomeworkByTeacherId(userId);
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _groups = groups;
          _homeworks = homeworks;
          if (_selectedSubjectId == null && subjects.isNotEmpty) _selectedSubjectId = subjects.first.id;
          if (_selectedGroupId == null && groups.isNotEmpty) _selectedGroupId = groups.first.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  Future<void> _pickFile() async {
    final file = await _fileService.pickFile();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _addHomework() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите предмет и группу')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? fileUrl;
      String? fileName;
      if (_selectedFile != null) {
        setState(() => _isUploadingFile = true);
        fileUrl = await _fileService.uploadFile(file: _selectedFile!, folderName: 'homework_files');
        fileName = _selectedFile!.name;
        setState(() => _isUploadingFile = false);
        if (fileUrl == null) throw Exception('Не удалось загрузить файл');
      }
      await _homeworkService.addHomework(
        institutionId: userProvider.institutionId!,
        subjectId: _selectedSubjectId!,
        groupId: _selectedGroupId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        dueDate: _dueDate,
        fileUrl: fileUrl,
        fileName: fileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Домашнее задание добавлено'), backgroundColor: Colors.green));
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _dueDate = null;
        _selectedFile = null;
      });
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDeleteHomework(Homework hw) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить задание?'),
            content: Text('Вы уверены, что хотите удалить "${hw.title}"?'),
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
      try {
        await _homeworkService.deleteHomework(hw.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задание удалено')));
        _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  void _showEditHomeworkDialog(Homework hw) {
    final editTitleController = TextEditingController(text: hw.title);
    final editDescriptionController = TextEditingController(text: hw.description ?? '');
    DateTime? editDueDate = hw.dueDate;
    String? editSelectedGroupId = hw.groupId;

    // Переменные для управления состоянием файла внутри диалога
    PlatformFile? editNewFile;
    bool isFileDeleted = false;
    bool isDialogUploading = false;

    final editFormKey = GlobalKey<FormState>();
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickFileForEdit() async {
              final file = await _fileService.pickFile();
              if (file != null) {
                setStateDialog(() {
                  editNewFile = file;
                  isFileDeleted = false;
                });
              }
            }

            return AlertDialog(
              title: Text('Редактировать ДЗ', style: TextStyle(color: colors.primary)),
              content: SingleChildScrollView(
                child: Form(
                  key: editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: editSelectedGroupId,
                        decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                        items: _groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                        onChanged: (val) => setStateDialog(() => editSelectedGroupId = val),
                        validator: (val) => val == null ? 'Выберите группу' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: editTitleController,
                        decoration: const InputDecoration(labelText: 'Заголовок', border: OutlineInputBorder()),
                        validator: (val) => Validators.requiredField(val, fieldName: 'Заголовок'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: editDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (editNewFile != null) ...[
                              Icon(Icons.upload_file, color: colors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  editNewFile!.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: colors.error),
                                tooltip: 'Отменить выбор',
                                onPressed: () => setStateDialog(() => editNewFile = null),
                              ),
                            ] else if (hw.fileUrl != null && !isFileDeleted) ...[
                              Icon(Icons.attachment, color: colors.secondary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(hw.fileName ?? 'Файл', overflow: TextOverflow.ellipsis)),
                              IconButton(
                                icon: Icon(Icons.edit, color: colors.primary),
                                tooltip: 'Заменить файл',
                                onPressed: pickFileForEdit,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: colors.error),
                                tooltip: 'Удалить файл',
                                onPressed: () => setStateDialog(() => isFileDeleted = true),
                              ),
                            ] else ...[
                              IconButton.filledTonal(onPressed: pickFileForEdit, icon: const Icon(Icons.attach_file)),
                              const SizedBox(width: 8),
                              const Expanded(child: Text('Прикрепить файл', style: TextStyle(color: Colors.grey))),
                              if (isFileDeleted)
                                IconButton(
                                  icon: const Icon(Icons.undo),
                                  tooltip: 'Вернуть старый файл',
                                  onPressed: () => setStateDialog(() => isFileDeleted = false),
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              editDueDate == null
                                  ? 'Дата сдачи не выбрана'
                                  : 'Срок: ${editDueDate!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: editDueDate == null ? colors.onSurfaceVariant : colors.onSurface),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: editDueDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setStateDialog(() => editDueDate = picked);
                            },
                            child: const Text('Изменить дату'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogUploading ? null : () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
                  onPressed:
                      isDialogUploading
                          ? null
                          : () async {
                            if (!editFormKey.currentState!.validate()) return;
                            if (editSelectedGroupId == null) return;
                            setStateDialog(() => isDialogUploading = true);
                            try {
                              String? newFileUrl;
                              String? newFileName;
                              if (editNewFile != null) {
                                newFileUrl = await _fileService.uploadFile(
                                  file: editNewFile!,
                                  folderName: 'homework_files',
                                );
                                newFileName = editNewFile!.name;
                                if (newFileUrl == null) throw Exception('Ошибка загрузки файла');
                              }
                              await _homeworkService.updateHomework(
                                id: hw.id,
                                title: editTitleController.text.trim(),
                                description: editDescriptionController.text.trim(),
                                dueDate: editDueDate,
                                groupId: editSelectedGroupId!,
                                fileUrl: newFileUrl,
                                fileName: newFileName,
                                deleteFile: editNewFile == null && isFileDeleted,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ДЗ обновлено'), backgroundColor: Colors.green),
                              );
                              _loadData();
                            } catch (e) {
                              setStateDialog(() => isDialogUploading = false);
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: colors.error));
                            }
                          },
                  child:
                      isDialogUploading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                          )
                          : const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Текущие задания',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.primary),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              if (widget.onTabRequest != null) {
                                widget.onTabRequest!(5);
                              }
                            },
                            icon: const Icon(Icons.check_box_outlined),
                            label: const Text('Проверка'),
                            style: TextButton.styleFrom(foregroundColor: colors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_homeworks.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Нет активных заданий', style: TextStyle(color: colors.onSurfaceVariant)),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _homeworks.length,
                          itemBuilder: (ctx, index) {
                            final hw = _homeworks[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: colors.surface,
                              child: ListTile(
                                title: Text(
                                  hw.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Группа: ${hw.group?.name ?? "—"}',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                    if (hw.dueDate != null)
                                      Text(
                                        'Срок: ${hw.dueDate!.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(
                                          color:
                                              hw.dueDate!.isBefore(DateTime.now())
                                                  ? colors.error
                                                  : colors.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colors.primary),
                                      tooltip: 'Изменить',
                                      onPressed: () => _showEditHomeworkDialog(hw),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: colors.error),
                                      tooltip: 'Удалить',
                                      onPressed: () => _confirmDeleteHomework(hw),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const Divider(height: 40, thickness: 1.5),
                      Text(
                        'Создать новое задание',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: colors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedSubjectId,
                                  decoration: const InputDecoration(labelText: 'Предмет', border: OutlineInputBorder()),
                                  items:
                                      _subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                                  onChanged: (val) => setState(() => _selectedSubjectId = val),
                                  validator: (val) => val == null ? 'Выберите предмет' : null,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedGroupId,
                                  decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                                  items:
                                      _groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                                  onChanged: (val) => setState(() => _selectedGroupId = val),
                                  validator: (val) => val == null ? 'Выберите группу' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Заголовок',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (val) => Validators.requiredField(val, fieldName: 'Заголовок'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Описание (опционально)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colors.outline),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      if (_selectedFile != null) ...[
                                        Icon(Icons.attach_file, color: colors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _selectedFile!.name,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close, color: colors.error),
                                          onPressed: () => setState(() => _selectedFile = null),
                                          tooltip: 'Удалить файл',
                                        ),
                                      ] else ...[
                                        IconButton.filledTonal(
                                          onPressed: _pickFile,
                                          icon: const Icon(Icons.upload_file),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Прикрепить файл (PDF, Doc, Img)',
                                          style: TextStyle(color: colors.onSurfaceVariant),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: colors.outline),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _dueDate == null
                                              ? 'Срок сдачи не выбран'
                                              : 'Срок: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(
                                            color: _dueDate == null ? colors.onSurfaceVariant : colors.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton.filled(
                                      onPressed: _selectDueDate,
                                      icon: const Icon(Icons.calendar_today),
                                      tooltip: 'Выбрать дату',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _isSaving ? null : _addHomework,
                                    icon:
                                        _isSaving
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                                            )
                                            : const Icon(Icons.add),
                                    label: const Text('Опубликовать задание'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
