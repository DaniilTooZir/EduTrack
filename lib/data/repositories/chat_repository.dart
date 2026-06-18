import 'dart:async';

import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/models/chat.dart';
import 'package:edu_track/models/message.dart';
import 'package:edu_track/utils/app_result.dart';

class ChatRepository {
  final ChatService _remote;
  final AppDatabase _local;

  ChatRepository({required ChatService remote, required AppDatabase local}) : _remote = remote, _local = local;

  // Cache-first: список чатов с превью
  Future<AppResult<List<ChatPreview>>> getEnrichedUserChats(String userId) async {
    final cachedRows = await _local.getChatPreviews(userId);
    if (cachedRows.isNotEmpty) {
      final previews = cachedRows.map(_rowToPreview).toList();
      unawaited(
        _remote.getEnrichedUserChats(userId).then((result) {
          if (result.isSuccess) _savePreviews(result.data, userId);
        }),
      );
      return AppResult.success(previews);
    }
    final result = await _remote.getEnrichedUserChats(userId);
    if (result.isSuccess) await _savePreviews(result.data, userId);
    return result;
  }

  // Cache-first: сообщения чата с инкрементальной синхронизацией
  Future<AppResult<List<Message>>> getMessages(String chatId) async {
    final cached = await _local.getMessagesByChatId(chatId);
    if (cached.isNotEmpty) {
      final since = cached.last.createdAt.subtract(const Duration(seconds: 1));
      unawaited(
        _remote.getMessagesSince(chatId, since).then((result) {
          if (result.isSuccess && result.data.isNotEmpty) _local.saveMessages(result.data);
        }),
      );
      return AppResult.success(cached);
    }
    final result = await _remote.getMessages(chatId);
    if (result.isSuccess) await _local.saveMessages(result.data);
    return result;
  }

  Future<void> cacheMessages(List<Message> messages) => _local.saveMessages(messages);

  // Только из локального кэша — без сетевого запроса
  Future<List<ChatPreview>> getCachedPreviews(String userId) async {
    final rows = await _local.getChatPreviews(userId);
    return rows.map(_rowToPreview).toList();
  }

  // Обновление превью чата при получении нового сообщения
  Future<void> updatePreviewLastMessage({
    required String chatId,
    String? lastMessage,
    required DateTime lastMessageTime,
    String? resetUnreadForUser,
    bool incrementUnread = false,
  }) => _local.updateChatPreviewLastMessage(
    chatId: chatId,
    lastMessage: lastMessage,
    lastMessageTime: lastMessageTime,
    resetUnreadForUser: resetUnreadForUser,
    incrementUnread: incrementUnread,
  );

  Future<AppResult<void>> sendMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    String? content,
    String? fileUrl,
    String? fileName,
  }) => _remote.sendMessage(
    chatId: chatId,
    senderId: senderId,
    senderRole: senderRole,
    content: content,
    fileUrl: fileUrl,
    fileName: fileName,
  );

  Future<AppResult<void>> markAsRead(String chatId, String userId) => _remote.markAsRead(chatId, userId);

  Future<AppResult<String>> getOrCreateDirectChat({
    required String myId,
    required String myRole,
    required String otherId,
    required String otherRole,
  }) => _remote.getOrCreateDirectChat(myId: myId, myRole: myRole, otherId: otherId, otherRole: otherRole);

  Future<AppResult<String>> getOrCreateGroupChat(String groupId, String groupName) =>
      _remote.getOrCreateGroupChat(groupId, groupName);

  Future<Map<String, String?>> getUserDetails(String userId, String role) => _remote.getUserDetails(userId, role);

  Future<List<Map<String, dynamic>>> getChatMembers(String chatId) => _remote.getChatMembers(chatId);

  Stream<List<Message>> getMessagesStream(String chatId) => _remote.getMessagesStream(chatId);

  Future<void> _savePreviews(List<ChatPreview> previews, String userId) async {
    for (final p in previews) {
      await _local.saveChatPreview(
        chatId: p.chat.id,
        userId: userId,
        title: p.title,
        avatarUrl: p.avatarUrl,
        lastMessage: p.lastMessage,
        lastMessageTime: p.lastMessageTime,
        unreadCount: p.unreadCount,
        chatType: p.chat.type,
        chatName: p.chat.name,
        chatGroupId: p.chat.groupId,
        chatUpdatedAt: p.chat.updatedAt,
      );
    }
  }

  ChatPreview _rowToPreview(LocalChatPreview row) {
    return ChatPreview(
      chat: Chat(
        id: row.chatId,
        type: row.chatType,
        name: row.chatName,
        groupId: row.chatGroupId,
        createdAt: DateTime.now(),
        updatedAt: row.chatUpdatedAt,
      ),
      title: row.title,
      avatarUrl: row.avatarUrl,
      lastMessage: row.lastMessage,
      lastMessageTime: row.lastMessageTime,
      unreadCount: row.unreadCount,
    );
  }
}
