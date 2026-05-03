import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/chat_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatService = ChatService();
  bool _isLoading = true;
  List<ChatPreview> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
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
                ? _buildChatListSkeleton()
                : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: _chats.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text('У вас пока нет диалогов', style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant)),
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
                  itemBuilder: (context, index) {
                    final chatPreview = _chats[index];
                    final isGroup = chatPreview.chat.type == 'group';
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
                          backgroundImage: chatPreview.avatarUrl != null ? NetworkImage(chatPreview.avatarUrl!) : null,
                          child:
                              chatPreview.avatarUrl == null
                                  ? Icon(
                                    isGroup ? Icons.groups : Icons.person,
                                    color: isGroup ? colors.onSecondaryContainer : colors.onPrimaryContainer,
                                  )
                                  : null,
                        ),
                        title: Text(
                          chatPreview.title,
                          style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          chatPreview.lastMessage ?? (isGroup ? 'Групповой чат' : 'Личное сообщение'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: chatPreview.isRead ? colors.onSurfaceVariant : colors.primary,
                            fontWeight: chatPreview.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (chatPreview.lastMessageTime != null)
                              Text(
                                "${chatPreview.lastMessageTime!.hour}:${chatPreview.lastMessageTime!.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                              ),
                            const SizedBox(height: 4),
                            if (!chatPreview.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chatPreview.chat.id, title: chatPreview.title),
                            ),
                          );
                          await _loadChats();
                        },
                      ),
                    );
                  },
                ),
                ),
      ),
    );
  }

  Widget _buildChatListSkeleton() {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(16),
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Skeleton(height: 56, width: 56, borderRadius: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(height: 16, width: 140),
                      const SizedBox(height: 10),
                      Skeleton(height: 12, width: MediaQuery.of(context).size.width * 0.5),
                    ],
                  ),
                ),
                const Skeleton(height: 12, width: 40),
              ],
            ),
          ),
    );
  }
}
