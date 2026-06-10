import 'package:edu_track/data/services/room_service.dart';
import 'package:edu_track/models/room.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/admin/simple_name_import_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/data_loading_mixin.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RoomAdminScreen extends StatefulWidget {
  const RoomAdminScreen({super.key});

  @override
  State<RoomAdminScreen> createState() => _RoomAdminScreenState();
}

class _RoomAdminScreenState extends State<RoomAdminScreen> with DataLoadingMixin {
  late final RoomService _roomService;
  List<Room> _rooms = [];
  bool _isAdding = false;
  String? _institutionId;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _roomNameAllowList = RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9\s\-\.\(\)\/]');

  List<Room> get _filteredRooms {
    if (_searchQuery.isEmpty) return _rooms;
    final q = _searchQuery.toLowerCase();
    return _rooms.where((r) => r.name.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _roomService = RoomService();
    _institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_institutionId == null) return;
    await loadAsync(_roomService.getRoomsForInstitution(_institutionId!), onSuccess: (data) => _rooms = data);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addRoom() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null) return;
    setState(() => _isAdding = true);
    final result = await _roomService.addRoom(name: _nameController.text.trim(), institutionId: _institutionId!);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      if (mounted) setState(() => _isAdding = false);
      return;
    }
    MessengerHelper.showSuccess('Аудитория успешно добавлена');
    _nameController.clear();
    if (!mounted) return;
    setState(() {
      _isAdding = false;
      _autovalidateMode = AutovalidateMode.disabled;
    });
    await _loadData();
  }

  Future<void> _editRoom(Room room) async {
    final editNameController = TextEditingController(text: room.name);
    final editFormKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text('Изменить аудиторию'),
                content: Form(
                  key: editFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    controller: editNameController,
                    decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                    inputFormatters: [FilteringTextInputFormatter.allow(_roomNameAllowList)],
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
                      final result = await _roomService.updateRoom(id: room.id, name: editNameController.text.trim());
                      if (result.isFailure) {
                        MessengerHelper.showError(result.errorMessage);
                        if (mounted) setState(() => isLoading = false);
                        return;
                      }
                      MessengerHelper.showSuccess('Аудитория обновлена');
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

  Future<void> _deleteRoom(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить аудиторию?'),
            content: Text('Вы уверены, что хотите удалить аудиторию "${room.name}"? Это затронет записи расписания.'),
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
      final result = await _roomService.deleteRoom(room.id);
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        if (mounted) setState(() => isLoading = false);
        return;
      }
      MessengerHelper.showSuccess('Аудитория удалена');
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
                              labelText: 'Название аудитории',
                              border: const OutlineInputBorder(),
                              prefixIcon: Icon(Icons.meeting_room, color: colors.primary),
                            ),
                            inputFormatters: [FilteringTextInputFormatter.allow(_roomNameAllowList)],
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
                              onPressed: _isAdding ? null : _addRoom,
                              child:
                                  _isAdding
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                                      )
                                      : const Text('Добавить аудиторию'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed:
                                  () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => SimpleNameImportScreen(
                                            title: 'Импорт аудиторий из CSV',
                                            entitySingular: 'аудитория',
                                            entityIcon: Icons.meeting_room_outlined,
                                            templateExample: '101\n202А\nАктовый зал',
                                            onBulkImport:
                                                (names) => _roomService.bulkAddRooms(
                                                  names: names,
                                                  institutionId: _institutionId!,
                                                ),
                                            onImportDone: _loadData,
                                          ),
                                    ),
                                  ),
                              icon: const Icon(Icons.upload_file_outlined),
                              label: const Text('Импорт из CSV'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Список аудиторий',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colors.primary),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Поиск аудитории',
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
                            : _filteredRooms.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text(
                                      'Список аудиторий пуст',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredRooms.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final room = _filteredRooms[index];
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: colors.primaryContainer,
                                      child: Icon(Icons.meeting_room, color: colors.onPrimaryContainer),
                                    ),
                                    title: Text(
                                      room.name,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _editRoom(room);
                                        if (value == 'delete') _deleteRoom(room);
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
