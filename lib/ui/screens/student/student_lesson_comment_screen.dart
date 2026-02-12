import 'package:edu_track/data/services/file_service.dart';
import 'package:edu_track/data/services/lesson_comment_service.dart';
import 'package:edu_track/models/lesson_comment.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentLessonCommentsScreen extends StatefulWidget {
  const StudentLessonCommentsScreen({super.key});

  @override
  State<StudentLessonCommentsScreen> createState() => _StudentLessonCommentsScreenState();
}

class _StudentLessonCommentsScreenState extends State<StudentLessonCommentsScreen> {
  final _service = LessonCommentService();
  final _fileService = FileService();
  final TextEditingController _messageController = TextEditingController();
  List<LessonComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  PlatformFile? _selectedFile;

  late final String lessonId;
  String? studentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      if (state.extra == null) {
        context.pop();
        return;
      }
      lessonId = state.extra as String;
      final provider = Provider.of<UserProvider>(context, listen: false);
      studentId = provider.userId;
      _loadComments();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final data = await _service.getCommentsByLessonId(lessonId.toString());
      if (!mounted) return;
      setState(() {
        _comments = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
    }
  }

  Future<void> _pickFile() async {
    final file = await _fileService.pickFile();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _sendComment() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    setState(() => _isSending = true);
    try {
      String? fileUrl;
      String? fileName;
      if (_selectedFile != null) {
        fileUrl = await _fileService.uploadFile(file: _selectedFile!, folderName: 'lesson_chat_files');
        fileName = _selectedFile!.name;
        if (fileUrl == null) throw Exception('Не удалось загрузить файл');
      }
      final comment = LessonComment(
        lessonId: lessonId.toString(),
        senderStudentId: studentId,
        message: text.isEmpty ? null : text,
        fileUrl: fileUrl,
        fileName: fileName,
        timestamp: DateTime.now(),
      );
      await _service.addComment(comment);
      if (!mounted) return;
      _messageController.clear();
      setState(() => _selectedFile = null);
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось отправить: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть файл')));
      }
    }
  }

  Widget _buildCommentBubble(LessonComment comment, ColorScheme colors) {
    final isMe = comment.senderStudentId == studentId;
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
            if (comment.senderTeacherId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Преподаватель',
                  style: TextStyle(fontSize: 10, color: colors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            if (comment.message != null && comment.message!.isNotEmpty)
              Text(comment.message!, style: TextStyle(color: textColor, fontSize: 15)),
            if (comment.fileUrl != null) ...[
              if (comment.message != null) const SizedBox(height: 8),
              InkWell(
                onTap: () => _openFile(comment.fileUrl!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
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
              _formatTimestamp(comment.timestamp),
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final localTime = timestamp.toLocal();
    final time = TimeOfDay.fromDateTime(localTime);
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Комментарии к занятию'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoading ? null : _loadComments)],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                    ? Center(child: Text('Нет комментариев', style: TextStyle(color: colors.onSurfaceVariant)))
                    : RefreshIndicator(
                      onRefresh: _loadComments,
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentBubble(comment, colors);
                        },
                      ),
                    ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: colors.surface),
            child: SafeArea(
              child: Column(
                children: [
                  if (_selectedFile != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            hintText: 'Введите сообщение...',
                            hintStyle: TextStyle(color: colors.onSurfaceVariant),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
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
          ),
        ],
      ),
    );
  }
}
