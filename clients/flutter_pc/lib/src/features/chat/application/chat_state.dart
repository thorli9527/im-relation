import '../../../data/models/conversation.dart';
import '../../../data/models/message.dart';

class ChatState {
  const ChatState({
    required this.conversations,
    required this.messages,
    required this.loadingConversations,
    required this.loadingMessages,
    required this.socketConnected,
    this.activeConversation,
    this.errorMessage,
  });

  final List<Conversation> conversations;
  final List<Message> messages;
  final bool loadingConversations;
  final bool loadingMessages;
  final Conversation? activeConversation;
  final String? errorMessage;
  final bool socketConnected;

  ChatState copyWith({
    List<Conversation>? conversations,
    List<Message>? messages,
    bool? loadingConversations,
    bool? loadingMessages,
    Conversation? activeConversation,
    String? errorMessage,
    bool clearError = false,
    bool? socketConnected,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      loadingConversations: loadingConversations ?? this.loadingConversations,
      loadingMessages: loadingMessages ?? this.loadingMessages,
      activeConversation: activeConversation ?? this.activeConversation,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      socketConnected: socketConnected ?? this.socketConnected,
    );
  }

  static ChatState initial() => const ChatState(
        conversations: [],
        messages: [],
        loadingConversations: false,
        loadingMessages: false,
        activeConversation: null,
        errorMessage: null,
        socketConnected: false,
      );
}
