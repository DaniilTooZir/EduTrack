import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/chat.dart';
import 'package:edu_track/models/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPreview {
  final Chat chat;
  final String title;
  final String? avatarUrl;
  final String? lastMessage;
  ChatPreview({required this.chat, required this.title, this.avatarUrl, this.lastMessage});
}

class ChatService {
  final SupabaseClient _client;
  ChatService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<List<Chat>> getUserChats(String userId) async {
    try {
      final response = await _client.from('chat_members').select('chat:chats(*)').eq('user_id', userId);
      final List<dynamic> data = response as List<dynamic>;
      final chats = data.map((e) => Chat.fromMap(e['chat'] as Map<String, dynamic>)).toList();
      chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return chats;
    } catch (e) {
      throw Exception('Ошибка загрузки чатов: $e');
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Message.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки сообщений: $e');
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    String? content,
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      await _client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_role': senderRole,
        'content': content,
        'file_url': fileUrl,
        'file_name': fileName,
        'created_at': DateTime.now().toIso8601String(),
      });
      await _client.from('chats').update({'updated_at': DateTime.now().toIso8601String()}).eq('id', chatId);
    } catch (e) {
      throw Exception('Ошибка отправки сообщения: $e');
    }
  }

  Future<String> getOrCreateDirectChat({
    required String myId,
    required String myRole,
    required String otherId,
    required String otherRole,
  }) async {
    try {
      final myChatsResponse = await _client
          .from('chat_members')
          .select('chat_id, chat:chats(type)')
          .eq('user_id', myId);
      final myChatIds =
          (myChatsResponse as List)
              .where((item) => item['chat']['type'] == 'direct')
              .map((item) => item['chat_id'] as String)
              .toList();
      if (myChatIds.isNotEmpty) {
        final commonChatResponse =
            await _client
                .from('chat_members')
                .select('chat_id')
                .eq('user_id', otherId)
                .filter('chat_id', 'in', '(${myChatIds.join(',')})')
                .maybeSingle();
        if (commonChatResponse != null) {
          return commonChatResponse['chat_id'] as String;
        }
      }
      final newChatResponse =
          await _client
              .from('chats')
              .insert({'type': 'direct', 'updated_at': DateTime.now().toIso8601String()})
              .select('id')
              .single();
      final newChatId = newChatResponse['id'] as String;
      await _client.from('chat_members').insert([
        {'chat_id': newChatId, 'user_id': myId, 'user_role': myRole},
        {'chat_id': newChatId, 'user_id': otherId, 'user_role': otherRole},
      ]);
      return newChatId;
    } catch (e) {
      throw Exception('Ошибка при создании чата: $e');
    }
  }

  Future<Map<String, String?>> getUserDetails(String userId, String role) async {
    String table;
    switch (role) {
      case 'student':
        table = 'students';
        break;
      case 'teacher':
        table = 'teachers';
        break;
      case 'admin':
        table = 'education_heads';
        break;
      case 'schedule_operator':
        table = 'schedule_operators';
        break;
      default:
        return {'name': 'Неизвестный', 'avatar': null};
    }
    try {
      final response = await _client.from(table).select('name, surname, avatar_url').eq('id', userId).single();
      final fullName = '${response['surname']} ${response['name']}';
      return {'name': fullName, 'avatar': response['avatar_url'] as String?};
    } catch (e) {
      return {'name': 'Пользователь удален', 'avatar': null};
    }
  }

  Future<Map<String, String?>> getChatInterlocutor(String chatId, String myId) async {
    try {
      final membersResponse =
          await _client
              .from('chat_members')
              .select('user_id, user_role')
              .eq('chat_id', chatId)
              .neq('user_id', myId)
              .single();
      return await getUserDetails(membersResponse['user_id'], membersResponse['user_role']);
    } catch (e) {
      return {'name': 'Собеседник', 'avatar': null};
    }
  }

  Future<String> getOrCreateGroupChat(String groupId, String groupName) async {
    try {
      final existingChat = await _client.from('chats').select('id').eq('group_id', groupId).maybeSingle();
      if (existingChat != null) {
        return existingChat['id'] as String;
      }
      final newChatResponse =
          await _client
              .from('chats')
              .insert({
                'type': 'group',
                'name': groupName,
                'group_id': groupId,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();
      final chatId = newChatResponse['id'] as String;
      await _syncGroupMembers(chatId, groupId);
      return chatId;
    } catch (e) {
      throw Exception('Ошибка при создании группового чата: $e');
    }
  }

  Future<void> _syncGroupMembers(String chatId, String groupId) async {
    final students = await _client.from('students').select('id').eq('group_id', groupId);
    final group = await _client.from('groups').select('curator_id').eq('id', groupId).single();
    final List<Map<String, dynamic>> membersToAdd = [];
    for (var s in students) {
      membersToAdd.add({'chat_id': chatId, 'user_id': s['id'], 'user_role': 'student'});
    }
    if (group['curator_id'] != null) {
      membersToAdd.add({'chat_id': chatId, 'user_id': group['curator_id'], 'user_role': 'teacher'});
    }
    if (membersToAdd.isNotEmpty) {
      await _client.from('chat_members').insert(membersToAdd);
    }
  }

  Future<List<ChatPreview>> getEnrichedUserChats(String userId) async {
    try {
      final response = await _client.from('chat_members').select('chat:chats(*)').eq('user_id', userId);
      final List<dynamic> data = response as List<dynamic>;
      final chats = data.map((e) => Chat.fromMap(e['chat'] as Map<String, dynamic>)).toList();
      chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final List<ChatPreview> previews = [];
      for (var chat in chats) {
        if (chat.type == 'group') {
          previews.add(ChatPreview(chat: chat, title: chat.name ?? 'Группа', avatarUrl: null));
        } else {
          final interlocutor = await getChatInterlocutor(chat.id, userId);
          previews.add(
            ChatPreview(chat: chat, title: interlocutor['name'] ?? 'Неизвестный', avatarUrl: interlocutor['avatar']),
          );
        }
      }
      return previews;
    } catch (e) {
      throw Exception('Ошибка загрузки списка чатов: $e');
    }
  }

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Message.fromMap(map)).toList());
  }
}
