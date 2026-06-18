import 'dart:async';

import 'package:edu_track/data/repositories/chat_repository.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/data/services/users_fetch_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/chat_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatRepository _chatRepo;
  String? _userId;
  bool _isLoading = true;
  List<ChatPreview> _chats = [];
  RealtimeChannel? _channel;
  Set<String>? _subscribedChatIds;
  Timer? _debounce;

  final _searchController = TextEditingController();
  bool _onlyUnread = false;

  List<ChatPreview> get _filteredChats {
    return _chats.where((c) {
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty && !c.title.toLowerCase().contains(q)) return false;
      if (_onlyUnread && c.isRead) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _chatRepo = Provider.of<ChatRepository>(context, listen: false);
    _loadChats();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _channel?.unsubscribe();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;
    _userId = userId;

    // Cache-first: сразу покажет кэш, в фоне обновится
    final result = await _chatRepo.getEnrichedUserChats(userId);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _chats = result.data;
        _isLoading = false;
      });
      _syncSubscription(userId);
    }
  }

  Future<void> _reloadFromCache() async {
    final userId = _userId;
    if (userId == null || !mounted) return;
    final previews = await _chatRepo.getCachedPreviews(userId);
    if (mounted) setState(() => _chats = previews);
  }

  void _syncSubscription(String userId) {
    final newIds = _chats.map((c) => c.chat.id).toSet();
    if (_subscribedChatIds != null &&
        _subscribedChatIds!.length == newIds.length &&
        _subscribedChatIds!.containsAll(newIds)) {
      return;
    }
    _subscribedChatIds = newIds;
    _channel?.unsubscribe();
    if (newIds.isEmpty) return;
    _channel =
        Supabase.instance.client
            .channel('chat_list_$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              callback: (payload) {
                final record = payload.newRecord;
                final chatId = record['chat_id'] as String?;
                if (chatId == null || !newIds.contains(chatId)) return;
                final content = record['content'] as String?;
                final fileUrl = record['file_url'] as String?;
                final createdAtStr = record['created_at'] as String?;
                final senderId = record['sender_id'] as String?;
                final lastMessageTime = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
                if (lastMessageTime == null) return;

                final isFromMe = senderId == userId;
                unawaited(
                  _chatRepo.updatePreviewLastMessage(
                    chatId: chatId,
                    lastMessage: content ?? (fileUrl != null ? '📎 Файл' : null),
                    lastMessageTime: lastMessageTime,
                    resetUnreadForUser: isFromMe ? userId : null,
                    incrementUnread: !isFromMe,
                  ),
                );
                unawaited(_reloadFromCache());
              },
            )
            .subscribe();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(time.year, time.month, time.day);
    if (msgDay == today) {
      return formatTime(time);
    } else if (msgDay == yesterday) {
      return 'Вчера';
    } else if (time.year == now.year) {
      return formatShortDate(time);
    } else {
      return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${(time.year % 100).toString().padLeft(2, '0')}';
    }
  }

  void _showNewChatBottomSheet() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    final userRole = userProvider.role;
    final institutionId = userProvider.institutionId;
    final groupId = userProvider.groupId;
    if (userId == null || userRole == null || institutionId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (_) => _NewChatSheet(
            userId: userId,
            userRole: userRole,
            institutionId: institutionId,
            groupId: groupId,
            onChatCreated: (chatId, title) async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId, title: title)));
              if (mounted) await _loadChats();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
          child:
              _isLoading
                  ? _buildSkeleton(colors)
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Поиск по чатам...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear)
                                        : null,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilterChip(
                                  label: const Text('Непрочитанные'),
                                  selected: _onlyUnread,
                                  onSelected: (v) => setState(() => _onlyUnread = v),
                                  avatar: Icon(
                                    Icons.mark_chat_unread_outlined,
                                    size: 16,
                                    color: _onlyUnread ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadChats,
                          child:
                              _chats.isEmpty
                                  ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.5,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 64,
                                                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(height: AppSpacing.l),
                                              Text(
                                                'У вас пока нет диалогов',
                                                style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : _filteredChats.isEmpty
                                  ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.4,
                                        child: Center(
                                          child: Text(
                                            'Ничего не найдено',
                                            style: TextStyle(color: colors.onSurfaceVariant),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(AppSpacing.l),
                                    itemCount: _filteredChats.length,
                                    itemBuilder: (context, index) => _buildChatTile(_filteredChats[index], colors),
                                  ),
                        ),
                      ),
                    ],
                  ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'new_chat_fab',
            onPressed: _showNewChatBottomSheet,
            tooltip: 'Новое сообщение',
            child: const Icon(Icons.edit_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(ChatPreview preview, ColorScheme colors) {
    final isGroup = preview.chat.type == 'group';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 2,
      color: colors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: isGroup ? colors.secondaryContainer : colors.primaryContainer,
          backgroundImage: preview.avatarUrl != null ? NetworkImage(preview.avatarUrl!) : null,
          child:
              preview.avatarUrl == null
                  ? Icon(
                    isGroup ? Icons.groups : Icons.person,
                    color: isGroup ? colors.onSecondaryContainer : colors.onPrimaryContainer,
                  )
                  : null,
        ),
        title: Text(
          preview.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          preview.lastMessage ?? (isGroup ? 'Групповой чат' : 'Личное сообщение'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: preview.isRead ? colors.onSurfaceVariant : colors.primary,
            fontWeight: preview.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_formatTime(preview.lastMessageTime), style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            const SizedBox(height: 4),
            if (preview.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  preview.unreadCount > 99 ? '99+' : '${preview.unreadCount}',
                  style: TextStyle(color: colors.onPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        onTap: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: preview.chat.id, title: preview.title)));
          await _loadChats();
        },
      ),
    );
  }

  Widget _buildSkeleton(ColorScheme colors) {
    return ListView.builder(
      itemCount: 7,
      padding: const EdgeInsets.all(AppSpacing.l),
      itemBuilder:
          (context, index) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            elevation: 2,
            color: colors.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Skeleton(height: 56, width: 56, borderRadius: 28),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 14, width: 140),
                        const SizedBox(height: 10),
                        Skeleton(height: 12, width: MediaQuery.of(context).size.width * 0.5),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Skeleton(height: 12, width: 40),
                ],
              ),
            ),
          ),
    );
  }
}

class _ContactEntry {
  final String id;
  final String role;
  final String displayName;
  final String subtitle;
  const _ContactEntry({required this.id, required this.role, required this.displayName, required this.subtitle});
}

class _NewChatSheet extends StatefulWidget {
  final String userId;
  final String userRole;
  final String institutionId;
  final String? groupId;
  final Future<void> Function(String chatId, String title) onChatCreated;

  const _NewChatSheet({
    required this.userId,
    required this.userRole,
    required this.institutionId,
    this.groupId,
    required this.onChatCreated,
  });

  @override
  State<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<_NewChatSheet> {
  final _chatService = ChatService();
  final _usersFetchService = UsersFetchService();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isStarting = false;
  List<_ContactEntry> _contacts = [];

  List<_ContactEntry> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts
        .where((c) => c.displayName.toLowerCase().contains(q) || c.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = <_ContactEntry>[];

    if (widget.userRole == 'student') {
      final groupId = widget.groupId;
      if (groupId != null) {
        final results = await Future.wait([
          _usersFetchService.fetchTeachersForGroup(groupId),
          _usersFetchService.fetchGroupmates(groupId),
        ]);
        if (results[0].isSuccess) {
          for (final t in results[0].data) {
            contacts.add(
              _ContactEntry(
                id: t['id'] as String,
                role: 'teacher',
                displayName: '${t['surname']} ${t['name']}',
                subtitle: 'Преподаватель',
              ),
            );
          }
        }
        if (results[1].isSuccess) {
          for (final s in results[1].data) {
            final id = s['id'] as String;
            if (id == widget.userId) continue;
            contacts.add(
              _ContactEntry(
                id: id,
                role: 'student',
                displayName: '${s['surname']} ${s['name']}',
                subtitle: s['group_name'] as String? ?? 'Студент',
              ),
            );
          }
        }
      }
    } else if (widget.userRole == 'teacher') {
      final results = await Future.wait([
        _usersFetchService.fetchTeachers(widget.institutionId),
        _usersFetchService.fetchStudentsForTeacher(widget.userId),
      ]);
      if (results[0].isSuccess) {
        for (final t in results[0].data) {
          final id = t['id'] as String;
          if (id == widget.userId) continue;
          contacts.add(
            _ContactEntry(
              id: id,
              role: 'teacher',
              displayName: '${t['surname']} ${t['name']}',
              subtitle: 'Преподаватель',
            ),
          );
        }
      }
      if (results[1].isSuccess) {
        for (final s in results[1].data) {
          contacts.add(
            _ContactEntry(
              id: s['id'] as String,
              role: 'student',
              displayName: '${s['surname']} ${s['name']}',
              subtitle: s['group_name'] as String? ?? 'Студент',
            ),
          );
        }
      }
    } else {
      // Оператор расписания: все преподаватели и студенты учреждения
      final results = await Future.wait([
        _usersFetchService.fetchTeachers(widget.institutionId),
        _usersFetchService.fetchStudents(widget.institutionId),
      ]);
      if (results[0].isSuccess) {
        for (final t in results[0].data) {
          final id = t['id'] as String;
          if (id == widget.userId) continue;
          contacts.add(
            _ContactEntry(
              id: id,
              role: 'teacher',
              displayName: '${t['surname']} ${t['name']}',
              subtitle: 'Преподаватель',
            ),
          );
        }
      }
      if (results[1].isSuccess) {
        for (final s in results[1].data) {
          final id = s['id'] as String;
          if (id == widget.userId) continue;
          contacts.add(
            _ContactEntry(
              id: id,
              role: 'student',
              displayName: '${s['surname']} ${s['name']}',
              subtitle: s['group_name'] as String? ?? 'Студент',
            ),
          );
        }
      }
    }

    contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    if (mounted) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  Future<void> _startChat(_ContactEntry contact) async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    final result = await _chatService.getOrCreateDirectChat(
      myId: widget.userId,
      myRole: widget.userRole,
      otherId: contact.id,
      otherRole: contact.role,
    );
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      setState(() => _isStarting = false);
      return;
    }
    Navigator.pop(context);
    await widget.onChatCreated(result.data, contact.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Новое сообщение',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Поиск...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear)
                          : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filtered.isEmpty
                      ? Center(
                        child: Text(
                          _contacts.isEmpty ? 'Нет доступных контактов' : 'Ничего не найдено',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                      : ListView.builder(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final c = _filtered[index];
                          final isTeacher = c.role == 'teacher';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isTeacher ? colors.secondaryContainer : colors.primaryContainer,
                              child: Text(
                                c.displayName.isNotEmpty ? c.displayName[0] : '?',
                                style: TextStyle(
                                  color: isTeacher ? colors.onSecondaryContainer : colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                            title: Text(c.displayName),
                            subtitle: Text(c.subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                            onTap: _isStarting ? null : () => _startChat(c),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}
