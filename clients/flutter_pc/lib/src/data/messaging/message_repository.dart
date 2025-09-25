import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../sample/sample_data.dart';

class MessageRepository {
  MessageRepository(this._client);

  final ApiClient _client;

  Future<List<Conversation>> fetchRecentConversations() async {
    try {
      final data = await _client.get('/msg/friend/recent');
      final list = (data['list'] as List<dynamic>?) ?? const <dynamic>[];
      return list
          .map((item) => Conversation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiClientException {
      rethrow;
    } on DioException {
      return SampleData.conversations();
    } catch (_) {
      return SampleData.conversations();
    }
  }

  Future<List<Message>> fetchHistory(String conversationId) async {
    try {
      final data = await _client.get(
        '/msg/friend/history',
        queryParameters: {'conversationId': conversationId},
      );
      final list = (data['list'] as List<dynamic>?) ?? const <dynamic>[];
      return list
          .map((item) => Message.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiClientException {
      rethrow;
    } on DioException {
      return SampleData.messagesFor(conversationId);
    } catch (_) {
      return SampleData.messagesFor(conversationId);
    }
  }

  Future<Message> sendText({
    required String conversationId,
    required String content,
    required String senderId,
  }) async {
    final optimistic = Message(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      direction: MessageDirection.outgoing,
      status: MessageStatus.sending,
    );
    try {
      final response = await _client.post('/msg/friend/send', data: {
        'conversationId': conversationId,
        'content': content,
      });
      if (response.isEmpty) {
        return optimistic.copyWith(status: MessageStatus.delivered);
      }
      return optimistic.copyWith(
        id: response['id']?.toString() ?? optimistic.id,
        status: MessageStatus.delivered,
        timestamp: response['timestamp'] != null
            ? DateTime.tryParse(response['timestamp'].toString()) ??
                optimistic.timestamp
            : optimistic.timestamp,
      );
    } on DioException {
      return optimistic.copyWith(status: MessageStatus.sent);
    } on ApiClientException {
      rethrow;
    }
  }
}
