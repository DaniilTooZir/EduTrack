import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/data/services/file_service.dart';
import 'package:edu_track/models/message.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String title;
  const ChatScreen({super.key, required this.chatId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _fileService = FileService();
  final _messageController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isSending = false;

  void _markChatAsRead() {
    final myId = Provider.of<UserProvider>(context, listen: false).userId;
    if (myId != null) {
      _chatService.markAsRead(widget.chatId, myId);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markChatAsRead());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await _fileService.pickFile();
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    if (result.data != null) {
      setState(() => _selectedFile = result.data);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    setState(() => _isSending = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    String? fileUrl;
    String? fileName;
    if (_selectedFile != null) {
      final uploadResult = await _fileService.uploadFile(file: _selectedFile!, folderName: 'chat_files');
      if (uploadResult.isFailure) {
        MessengerHelper.showError(uploadResult.errorMessage);
        if (mounted) setState(() => _isSending = false);
        return;
      }
      fileUrl = uploadResult.data;
      fileName = _selectedFile!.name;
    }

    final result = await _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: userProvider.userId!,
      senderRole: userProvider.role!,
      content: text.isEmpty ? null : text,
      fileUrl: fileUrl,
      fileName: fileName,
    );

    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else if (mounted) {
      _messageController.clear();
      setState(() => _selectedFile = null);
    }

    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  final Map<String, String> _userNameCache = {};

  Future<String> _getUserName(String userId, String role) async {
    if (_userNameCache.containsKey(userId)) return _userNameCache[userId]!;
    final details = await _chatService.getUserDetails(userId, role);
    final name = details['name'] ?? 'Неизвестный';
    _userNameCache[userId] = name;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final myId = Provider.of<UserProvider>(context, listen: false).userId;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(Provider.of<ThemeProvider>(context).mode)),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _chatService.getMessagesStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return _buildMessagesSkeleton();
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) => _markChatAsRead());
                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return Center(child: Text('Сообщений пока нет', style: TextStyle(color: colors.onSurfaceVariant)));
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == myId;
                      bool showDateSeparator = false;
                      if (index == messages.length - 1) {
                        showDateSeparator = true;
                      } else {
                        final prevMessage = messages[index + 1];
                        if (message.createdAt.day != prevMessage.createdAt.day) {
                          showDateSeparator = true;
                        }
                      }
                      return Column(
                        children: [
                          if (showDateSeparator)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatSeparatorDate(message.createdAt),
                                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                                  ),
                                ),
                              ),
                            ),
                          _buildMessageBubble(message, isMe, colors),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputArea(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe, ColorScheme colors) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              FutureBuilder<String>(
                future: _getUserName(message.senderId, message.senderRole),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      snapshot.data ?? '...',
                      style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? colors.primaryContainer : colors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  if (!isMe)
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.content != null)
                      Text(
                        message.content!,
                        style: TextStyle(color: isMe ? colors.onPrimaryContainer : colors.onSurface),
                      ),
                    if (message.fileUrl != null) ...[
                      if (message.fileUrl!.toLowerCase().endsWith('.jpg') ||
                          message.fileUrl!.toLowerCase().endsWith('.png') ||
                          message.fileUrl!.toLowerCase().endsWith('.jpeg'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.fileUrl!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        )
                      else if (message.content != null)
                        const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openFile(message.fileUrl!),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white.withOpacity(0.3) : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 16,
                                color: isMe ? colors.onPrimaryContainer : colors.onSurface,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  message.fileName ?? 'Файл',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe ? colors.onPrimaryContainer : colors.onSurface,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Align(
                      alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMe) const SizedBox(width: 20),
                          Text(
                            "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isMe
                                      ? colors.onPrimaryContainer.withOpacity(0.5)
                                      : colors.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: message.isRead ? Colors.blue : colors.onPrimaryContainer.withOpacity(0.3),
                            ),
                          ],
                          if (!isMe) const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.outlineVariant))),
      child: SafeArea(
        child: Column(
          children: [
            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        style: TextStyle(color: colors.onSecondaryContainer),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _selectedFile = null),
                      color: colors.onSecondaryContainer,
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: colors.onSurfaceVariant),
                  onPressed: _isSending ? null : _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendMessage,
                  icon:
                      _isSending
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                          )
                          : const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSeparatorDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Сегодня';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.day == yesterday.day && date.month == yesterday.month && date.year == yesterday.year) {
      return 'Вчера';
    }
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return months[month - 1];
  }

  Widget _buildMessagesSkeleton() {
    return ListView.builder(
      reverse: true,
      itemCount: 8,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Skeleton(height: 50, width: 150 + (index * 20 % 100).toDouble(), borderRadius: 16),
          ),
        );
      },
    );
  }
}
