import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_providers.dart';
import '../../../data/api/api_client.dart';
import '../../../data/contacts/contact_repository.dart';
import '../../../data/messaging/message_repository.dart';
import '../../../data/models/auth_session.dart';
import '../../../data/models/conversation.dart';
import '../../../data/models/message.dart';
import '../../../data/sample/sample_data.dart';
import 'chat_state.dart';

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._ref) : super(ChatState.initial());

  final Ref _ref;
  AuthSession? _session;
  StreamSubscription<Message>? _socketSubscription;

  Future<void> bootstrap({required AuthSession session}) async {
    _session = session;
    state = state.copyWith(
      loadingConversations: true,
      errorMessage: null,
    );

    List<Conversation> conversations = [];
    try {
      conversations = await _ref
          .read(messageRepositoryProvider)
          .fetchRecentConversations();
    } on ApiClientException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      conversations = SampleData.conversations();
    }

    if (conversations.isEmpty) {
      conversations = SampleData.conversations();
    }

    final activeConversation =
        conversations.isNotEmpty ? conversations.first : null;
    state = state.copyWith(
      conversations: conversations,
      loadingConversations: false,
      activeConversation: activeConversation,
    );

    if (activeConversation != null) {
      await loadMessages(activeConversation.id);
    }

    await _connectSocket();
  }

  Future<void> loadMessages(String conversationId) async {
    final fallback = SampleData
        .conversationForContact(SampleData.contacts().first)
        .copyWith(id: conversationId);
    final active = state.conversations.firstWhere(
      (item) => item.id == conversationId,
      orElse: () => state.activeConversation ?? fallback,
    );

    state = state.copyWith(
      activeConversation: active,
      loadingMessages: true,
      clearError: true,
    );

    try {
      final messages = await _ref
          .read(messageRepositoryProvider)
          .fetchHistory(conversationId);
      state = state.copyWith(messages: messages, loadingMessages: false);
    } on ApiClientException catch (error) {
      state = state.copyWith(
        messages: SampleData.messagesFor(conversationId),
        loadingMessages: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        messages: SampleData.messagesFor(conversationId),
        loadingMessages: false,
      );
    }
  }

  Future<void> sendMessage(String content) async {
    final session = _session;
    final conversation = state.activeConversation;
    if (session == null || conversation == null) {
      return;
    }
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final optimistic = Message(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversation.id,
      senderId: session.user.id,
      content: trimmed,
      timestamp: DateTime.now(),
      direction: MessageDirection.outgoing,
      status: MessageStatus.sending,
    );

    final updatedMessages = [...state.messages, optimistic];
    state = state.copyWith(messages: updatedMessages, clearError: true);

    try {
      final sent = await _ref.read(messageRepositoryProvider).sendText(
            conversationId: conversation.id,
            content: trimmed,
            senderId: session.user.id,
          );
      _replaceMessage(optimistic.id, sent);
      _updateConversationPreview(conversation.id, sent.content, sent.timestamp);
    } on ApiClientException catch (error) {
      _replaceMessage(
        optimistic.id,
        optimistic.copyWith(status: MessageStatus.failed),
      );
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      _replaceMessage(
        optimistic.id,
        optimistic.copyWith(status: MessageStatus.sent),
      );
    }
  }

  Future<void> addFriend(String query) async {
    try {
      final contact = await _ref.read(contactRepositoryProvider).addFriend(query);
      final conversation = await _ref
          .read(contactRepositoryProvider)
          .buildConversation(contact);
      final updatedList = [conversation, ...state.conversations];
      state = state.copyWith(conversations: updatedList);
    } on ApiClientException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      rethrow;
    }
  }

  Future<void> _connectSocket() async {
    final session = _session;
    if (session == null) return;

    await _socketSubscription?.cancel();
    final socket = _ref.read(socketServiceProvider);
    await socket.connect(session);
    _socketSubscription = socket.messages.listen(_handleIncomingMessage);
    state = state.copyWith(socketConnected: true);
  }

  void _handleIncomingMessage(Message message) {
    final existingConversation = state.conversations
        .firstWhere((item) => item.id == message.conversationId,
            orElse: () => Conversation(
                  id: message.conversationId,
                  contact: SampleData.contacts().first,
                ));

    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == existingConversation.id) {
        final unread = state.activeConversation?.id == conv.id
            ? 0
            : conv.unreadCount + (message.isOutgoing ? 0 : 1);
        return conv.copyWith(
          lastMessagePreview: message.content,
          lastTimestamp: message.timestamp,
          unreadCount: unread,
        );
      }
      return conv;
    }).toList();

    if (!state.conversations.any((c) => c.id == existingConversation.id)) {
      updatedConversations.insert(0, existingConversation.copyWith(
        lastMessagePreview: message.content,
        lastTimestamp: message.timestamp,
        isPinned: false,
      ));
    }

    if (state.activeConversation?.id == existingConversation.id) {
      final activeUpdated = updatedConversations
          .firstWhere((conv) => conv.id == existingConversation.id);
      final updatedMessages = [...state.messages, message];
      state = state.copyWith(
        conversations: updatedConversations,
        messages: updatedMessages,
        activeConversation: activeUpdated,
      );
    } else {
      state = state.copyWith(conversations: updatedConversations);
    }
  }

  void _replaceMessage(String tempId, Message replacement) {
    final updated = state.messages.map((message) {
      if (message.id == tempId) {
        return replacement;
      }
      return message;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  void _updateConversationPreview(
    String conversationId,
    String lastMessage,
    DateTime timestamp,
  ) {
    final updated = state.conversations.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(
          lastMessagePreview: lastMessage,
          lastTimestamp: timestamp,
          unreadCount: 0,
        );
      }
      return conversation;
    }).toList();
    state = state.copyWith(conversations: updated);
  }

  Future<void> reset() async {
    _session = null;
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _ref.read(socketServiceProvider).disconnect();
    state = ChatState.initial();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
