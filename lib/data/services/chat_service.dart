import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/chat.dart';
import 'package:edu_track/models/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
