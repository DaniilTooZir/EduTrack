import 'package:edu_track/data/services/file_service.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/messenger_helper.dart';
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId!;
    final institutionId = userProvider.institutionId!;
    final subjectsResult = await _subjectService.getSubjectsByTeacherId(userId);
    if (subjectsResult.isFailure) {
      if (mounted) setState(() => _isLoading = false);
      MessengerHelper.showError(subjectsResult.errorMessage);
      return;
    }
    final groupsResult = await _groupService.getGroups(institutionId);
    if (groupsResult.isFailure) {
      if (mounted) setState(() => _isLoading = false);
      MessengerHelper.showError(groupsResult.errorMessage);
      return;
    }
    final homeworksResult = await _homeworkService.getHomeworkByTeacherId(userId);
    if (homeworksResult.isFailure) {
      if (mounted) setState(() => _isLoading = false);
      MessengerHelper.showError(homeworksResult.errorMessage);
      return;
    }
    if (mounted) {
      setState(() {
        _subjects = subjectsResult.data;
        _groups = groupsResult.data;
        _homeworks = homeworksResult.data;
        if (_selectedSubjectId == null && _subjects.isNotEmpty) _selectedSubjectId = _subjects.first.id;
        if (_selectedGroupId == null && _groups.isNotEmpty) _selectedGroupId = _groups.first.id;
        _isLoading = false;
      });
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
    final result = await _fileService.pickFile();
    if (result.isSuccess && result.data != null) {
      setState(() => _selectedFile = result.data);
    }
  }

  Future<void> _addHomework() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _selectedGroupId == null) {
      MessengerHelper.showError('Выберите предмет и группу');
      return;
    }
    setState(() => _isSaving = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? fileUrl;
    String? fileName;
    if (_selectedFile != null) {
      setState(() => _isUploadingFile = true);
      final uploadResult = await _fileService.uploadFile(file: _selectedFile!, folderName: 'homework_files');
      setState(() => _isUploadingFile = false);
      if (uploadResult.isFailure) {
        MessengerHelper.showError(uploadResult.errorMessage);
        if (mounted) setState(() => _isSaving = false);
        return;
      }
      fileUrl = uploadResult.data;
      fileName = _selectedFile!.name;
    }
    final addResult = await _homeworkService.addHomework(
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
    if (addResult.isFailure) {
      MessengerHelper.showError(addResult.errorMessage);
      setState(() => _isSaving = false);
      return;
    }
    MessengerHelper.showSuccess('Домашнее задание добавлено');
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _dueDate = null;
      _selectedFile = null;
      _isSaving = false;
    });
    await _loadData();
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
      final result = await _homeworkService.deleteHomework(hw.id);
      if (!mounted) return;
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        return;
      }
      MessengerHelper.showSuccess('Задание удалено');
      _loadData();
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
              final result = await _fileService.pickFile();
              if (result.isSuccess && result.data != null) {
                setStateDialog(() {
                  editNewFile = result.data;
                  isFileDeleted = false;
                });
              }
            }

            return AlertDialog(
              title: Text('Редактировать ДЗ', style: TextStyle(color: colors.primary)),
              content: SingleChildScrollView(
                child: Form(
                  key: editFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: editSelectedGroupId,
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
                              final DateTime minDate = DateTime.now().subtract(const Duration(days: 30));
                              final DateTime safeFirstDate =
                                  (editDueDate != null && editDueDate!.isBefore(minDate)) ? editDueDate! : minDate;
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: editDueDate ?? DateTime.now(),
                                firstDate: safeFirstDate,
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
                            String? newFileUrl;
                            String? newFileName;
                            if (editNewFile != null) {
                              final uploadResult = await _fileService.uploadFile(
                                file: editNewFile!,
                                folderName: 'homework_files',
                              );
                              if (uploadResult.isFailure) {
                                setStateDialog(() => isDialogUploading = false);
                                MessengerHelper.showError(uploadResult.errorMessage);
                                return;
                              }
                              newFileUrl = uploadResult.data;
                              newFileName = editNewFile!.name;
                            }
                            final updateResult = await _homeworkService.updateHomework(
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
                            if (updateResult.isFailure) {
                              setStateDialog(() => isDialogUploading = false);
                              MessengerHelper.showError(updateResult.errorMessage);
                              return;
                            }
                            Navigator.pop(context);
                            MessengerHelper.showSuccess('ДЗ обновлено');
                            _loadData();
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedSubjectId,
                                  decoration: const InputDecoration(labelText: 'Предмет', border: OutlineInputBorder()),
                                  items:
                                      _subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                                  onChanged: (val) => setState(() => _selectedSubjectId = val),
                                  validator: (val) => val == null ? 'Выберите предмет' : null,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedGroupId,
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
