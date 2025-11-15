import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/lesson_comment.dart';
import 'package:edu_track/data/services/lesson_comment_service.dart';
import 'package:edu_track/providers/user_provider.dart';

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
  late final int lessonId;
  String? studentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      lessonId = state.extra as int;
      final provider = Provider.of<UserProvider>(context, listen: false);
      studentId = provider.userId;
      _loadComments();
    });
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _service.getCommentsByLessonId(lessonId);
    if (!mounted) return;
    setState(() {
      _comments = data;
      _isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final comment = LessonComment(
      lessonId: lessonId,
      senderStudentId: studentId,
      senderTeacherId: null,
      message: text,
      timestamp: DateTime.now(),
    );
    final success = await _service.addComment(comment);
    if (!mounted) return;
    if (success) {
      _messageController.clear();
      await _loadComments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка при отправке комментария')));
    }
  }

  Widget _buildCommentBubble(LessonComment comment) {
    final isMe = comment.senderStudentId == studentId;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Colors.deepPurple.shade100 : Colors.grey.shade200;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: align,
          children: [
            Text(comment.message ?? ''),
            const SizedBox(height: 4),
            Text(_formatTimestamp(comment.timestamp), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final time = TimeOfDay.fromDateTime(timestamp);
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Комментарии к занятию')),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      reverse: true,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[_comments.length - index - 1];
                        return _buildCommentBubble(comment);
                      },
                    ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Введите сообщение...', border: InputBorder.none),
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.deepPurple), onPressed: _sendComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
