import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/chat_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
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
    try {
      final chats = await _chatService.getEnrichedUserChats(userId);
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                ? const Center(child: CircularProgressIndicator())
                : _chats.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: colors.onSurfaceVariant.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('У вас пока нет диалогов', style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant)),
                    ],
                  ),
                )
                : ListView.builder(
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
                          isGroup ? 'Групповой чат' : 'Личное сообщение',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chatPreview.chat.id, title: chatPreview.title),
                            ),
                          );
                          _loadChats();
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
