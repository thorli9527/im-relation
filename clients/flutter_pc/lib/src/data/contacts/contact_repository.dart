import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/contact.dart';
import '../models/conversation.dart';
import '../sample/sample_data.dart';

class ContactRepository {
  ContactRepository(this._client);

  final ApiClient _client;

  Future<List<Contact>> fetchContacts() async {
    try {
      final data = await _client.get('/friend/list');
      final list = (data['list'] as List<dynamic>?) ??
          (data['friends'] as List<dynamic>?) ??
          const <dynamic>[];
      return list
          .map((item) => Contact.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiClientException {
      rethrow;
    } on DioException {
      return SampleData.contacts();
    } catch (_) {
      return SampleData.contacts();
    }
  }

  Future<Contact> addFriend(String query) async {
    try {
      final response = await _client.post('/friend/add', data: {'target': query});
      if (response.isEmpty) {
        return Contact(
          id: query,
          displayName: query,
          description: '好友请求已发送',
          isOnline: false,
        );
      }
      return Contact.fromJson(response);
    } on ApiClientException {
      rethrow;
    } on DioException {
      return Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        displayName: query,
        description: '已发送好友请求，等待对方响应',
        isOnline: false,
      );
    }
  }

  Future<Conversation> buildConversation(Contact contact) async {
    return SampleData.conversationForContact(contact);
  }
}
