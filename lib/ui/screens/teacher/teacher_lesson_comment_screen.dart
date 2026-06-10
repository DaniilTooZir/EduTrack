import 'package:edu_track/data/services/file_service.dart';
import 'package:edu_track/data/services/lesson_comment_service.dart';
import 'package:edu_track/models/lesson_comment.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonCommentsScreen extends StatefulWidget {
  final String lessonId;
  const LessonCommentsScreen({super.key, required this.lessonId});

  @override
  State<LessonCommentsScreen> createState() => _LessonCommentsScreenState();
}

class _LessonCommentsScreenState extends State<LessonCommentsScreen> {
  final _service = LessonCommentService();
  final _fileService = FileService();
  final _messageController = TextEditingController();

  final Map<String, Future<String>> _senderNameFutures = {};

  bool _isSending = false;
  PlatformFile? _selectedFile;
  String? userId;
  String? userRole;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    userId = provider.userId;
    userRole = provider.role;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<String> _getSenderFuture(String id, String role) =>
      _senderNameFutures.putIfAbsent(id, () => _service.getSenderName(id, role));

  Future<void> _pickFile() async {
    final result = await _fileService.pickFile();
    if (result.isSuccess && result.data != null) {
      setState(() => _selectedFile = result.data);
    }
  }

  Future<void> _sendComment() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    setState(() => _isSending = true);

    String? fileUrl;
    String? fileName;
    if (_selectedFile != null) {
      final uploadResult = await _fileService.uploadFile(file: _selectedFile!, folderName: 'lesson_chat_files');
      if (!mounted) return;
      if (uploadResult.isFailure) {
        setState(() => _isSending = false);
        MessengerHelper.showError(uploadResult.errorMessage);
        return;
      }
      fileUrl = uploadResult.data;
      fileName = _selectedFile!.name;
    }

    final comment = LessonComment(
      lessonId: widget.lessonId,
      senderTeacherId: userRole == 'teacher' ? userId : null,
      senderStudentId: userRole == 'student' ? userId : null,
      message: text.isEmpty ? null : text,
      fileUrl: fileUrl,
      fileName: fileName,
      timestamp: DateTime.now(),
    );

    final result = await _service.addComment(comment);
    if (!mounted) return;
    setState(() => _isSending = false);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    _messageController.clear();
    setState(() => _selectedFile = null);
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      MessengerHelper.showError('Не удалось открыть файл');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Комментарии')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<LessonComment>>(
              stream: _service.getCommentsStream(widget.lessonId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки', style: TextStyle(color: colors.error)));
                }
                if (!snapshot.hasData) return _buildLoadingSkeleton();
                final comments = snapshot.data!;
                if (comments.isEmpty) {
                  return Center(child: Text('Нет комментариев', style: TextStyle(color: colors.onSurfaceVariant)));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final showSeparator =
                        index == comments.length - 1 || !_sameDay(comment.timestamp, comments[index + 1].timestamp);
                    return Column(
                      children: [
                        if (showSeparator) _buildDateSeparator(comment.timestamp, colors),
                        _buildCommentBubble(comment, colors),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          _buildInputArea(colors),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateSeparator(DateTime date, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_formatSeparatorDate(date), style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        ),
      ),
    );
  }

  String _formatSeparatorDate(DateTime date) {
    final now = DateTime.now();
    if (_sameDay(date, now)) return 'Сегодня';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_sameDay(date, yesterday)) return 'Вчера';
    return formatShortDate(date);
  }

  Widget _buildCommentBubble(LessonComment comment, ColorScheme colors) {
    final isMe =
        (userRole == 'teacher' && comment.senderTeacherId == userId) ||
        (userRole == 'student' && comment.senderStudentId == userId);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? colors.primaryContainer : colors.surfaceContainerHighest;
    final textColor = isMe ? colors.onPrimaryContainer : colors.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: align,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) _buildSenderLabel(comment, colors),
            if (comment.message != null && comment.message!.isNotEmpty)
              Text(comment.message!, style: TextStyle(color: textColor, fontSize: 15)),
            if (comment.fileUrl != null) ...[
              if (comment.message != null && comment.message!.isNotEmpty) const SizedBox(height: 8),
              InkWell(
                onTap: () => _openFile(comment.fileUrl!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.description, size: 20, color: textColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          comment.fileName ?? 'Файл',
                          style: TextStyle(color: textColor, fontSize: 13, decoration: TextDecoration.underline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              formatTime(comment.timestamp.toLocal()),
              style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderLabel(LessonComment comment, ColorScheme colors) {
    final String? senderId;
    final String role;
    if (comment.senderTeacherId != null) {
      senderId = comment.senderTeacherId;
      role = 'teacher';
    } else if (comment.senderStudentId != null) {
      senderId = comment.senderStudentId;
      role = 'student';
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: FutureBuilder<String>(
        future: _getSenderFuture(senderId!, role),
        builder:
            (context, snapshot) => Text(
              snapshot.data ?? '...',
              style: TextStyle(fontSize: 10, color: colors.primary, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: colors.surface),
      child: SafeArea(
        child: Column(
          children: [
            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 20, color: colors.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        style: TextStyle(color: colors.onSecondaryContainer),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close, size: 20, color: colors.onSecondaryContainer),
                      onPressed: () => setState(() => _selectedFile = null),
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
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      hintStyle: TextStyle(color: colors.onSurfaceVariant),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon:
                      _isSending
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                          )
                          : const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
                  onPressed:
                      (_messageController.text.trim().isEmpty && _selectedFile == null) || _isSending
                          ? null
                          : _sendComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    const bubbles = [(true, 180.0), (false, 140.0), (true, 220.0), (false, 110.0), (true, 160.0), (false, 200.0)];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children:
          bubbles
              .map(
                (b) => Align(
                  alignment: b.$1 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Skeleton(height: 52, width: b.$2, borderRadius: 16),
                  ),
                ),
              )
              .toList(),
    );
  }
}
