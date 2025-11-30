import 'package:edu_track/data/services/lesson_comment_service.dart';
import 'package:edu_track/models/lesson_comment.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentLessonCommentsScreen extends StatefulWidget {
  const StudentLessonCommentsScreen({super.key});

  @override
  State<StudentLessonCommentsScreen> createState() => _StudentLessonCommentsScreenState();
}

class _StudentLessonCommentsScreenState extends State<StudentLessonCommentsScreen> {
  final _service = LessonCommentService();
  final TextEditingController _messageController = TextEditingController();
  List<LessonComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  late final int lessonId;
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
      lessonId = state.extra as int;
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
      final data = await _service.getCommentsByLessonId(lessonId);
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

  Future<void> _sendComment() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final comment = LessonComment(
        lessonId: lessonId,
        senderStudentId: studentId,
        message: text,
        timestamp: DateTime.now(),
      );
      await _service.addComment(comment);
      if (!mounted) return;
      _messageController.clear();
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

  Widget _buildCommentBubble(LessonComment comment) {
    final isMe = comment.senderStudentId == studentId;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? const Color(0xFFD1C4E9) : Colors.grey.shade200;
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
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'Преподаватель',
                  style: TextStyle(fontSize: 10, color: Colors.deepPurple[700], fontWeight: FontWeight.bold),
                ),
              ),
            Text(comment.message ?? '', style: const TextStyle(color: Colors.black87, fontSize: 15)),
            const SizedBox(height: 4),
            Text(_formatTimestamp(comment.timestamp), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
                    ? const Center(child: Text('Нет комментариев', style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                      onRefresh: _loadComments,
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentBubble(comment);
                        },
                      ),
                    ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Введите сообщение...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (context, value, child) {
                      final isTextEmpty = value.text.trim().isEmpty;
                      return IconButton.filled(
                        icon:
                            _isSending
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                : const Icon(Icons.send),
                        style: IconButton.styleFrom(
                          backgroundColor: isTextEmpty || _isSending ? Colors.grey : const Color(0xFF5E35B1),
                        ),
                        onPressed: isTextEmpty || _isSending ? null : _sendComment,
                      );
                    },
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
