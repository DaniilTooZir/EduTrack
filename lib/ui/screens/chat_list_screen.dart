import 'dart:async';

import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/chat_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
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
  final _chatService = ChatService();
  bool _isLoading = true;
  List<ChatPreview> _chats = [];
  RealtimeChannel? _channel;
  Set<String>? _subscribedChatIds;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadChats() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;

    final result = await _chatService.getEnrichedUserChats(userId);
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
                final chatId = payload.newRecord['chat_id'] as String?;
                if (chatId != null && newIds.contains(chatId)) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), _loadChats);
                }
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
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (msgDay == yesterday) {
      return 'Вчера';
    } else if (time.year == now.year) {
      return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}';
    } else {
      return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${(time.year % 100).toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Сообщения')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child:
            _isLoading
                ? _buildSkeleton(colors)
                : RefreshIndicator(
                  onRefresh: _loadChats,
                  child:
                      _chats.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 64,
                                        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 16),
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
                          : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _chats.length,
                            itemBuilder: (context, index) => _buildChatTile(_chats[index], colors),
                          ),
                ),
      ),
    );
  }

  Widget _buildChatTile(ChatPreview preview, ColorScheme colors) {
    final isGroup = preview.chat.type == 'group';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      padding: const EdgeInsets.all(16),
      itemBuilder:
          (context, index) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            color: colors.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Skeleton(height: 56, width: 56, borderRadius: 28),
                  const SizedBox(width: 16),
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
