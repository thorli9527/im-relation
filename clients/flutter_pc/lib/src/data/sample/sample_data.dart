import 'dart:math';

import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

class SampleData {
  static final UserProfile demoUser = UserProfile(
    id: '100001',
    displayName: '桌面端 · Neo',
    avatarUrl:
        'https://avatars.githubusercontent.com/u/14101776?s=200&v=4',
    statusMessage: '与好友保持端到端加密通信',
    email: 'neo@example.com',
  );

  static final List<Contact> _contacts = [
    const Contact(
      id: '200001',
      displayName: 'Lena',
      avatarUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200',
      description: '安全产品经理 · 在线',
      isOnline: true,
    ),
    const Contact(
      id: '200002',
      displayName: 'Marcus',
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      description: '正在移动端设备登录',
      isOnline: true,
    ),
    const Contact(
      id: '200003',
      displayName: 'Aurora',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
      description: '离线 · 刚刚',
      isOnline: false,
    ),
  ];

  static final Map<String, List<Message>> _messages = {
    'conv-lena': [
      Message(
        id: 'm1',
        conversationId: 'conv-lena',
        senderId: '200001',
        content: '晚上的端到端加密演示准备好了吗？',
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        direction: MessageDirection.incoming,
        status: MessageStatus.delivered,
      ),
      Message(
        id: 'm2',
        conversationId: 'conv-lena',
        senderId: '100001',
        content: '刚调通桌面端登录流程，正在联调收发消息。',
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        direction: MessageDirection.outgoing,
        status: MessageStatus.delivered,
        isEncrypted: true,
      ),
      Message(
        id: 'm3',
        conversationId: 'conv-lena',
        senderId: '200001',
        content: '收到，记得演示一下多端在线状态同步 👌',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        direction: MessageDirection.incoming,
        status: MessageStatus.read,
      ),
    ],
    'conv-marcus': [
      Message(
        id: 'm10',
        conversationId: 'conv-marcus',
        senderId: '200002',
        content: 'Signal UI 那个毛玻璃渐变我非常喜欢。',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
        direction: MessageDirection.incoming,
        status: MessageStatus.delivered,
      ),
      Message(
        id: 'm11',
        conversationId: 'conv-marcus',
        senderId: '100001',
        content: '桌面端主题已经调好了，稍后发你设计稿。',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
        direction: MessageDirection.outgoing,
        status: MessageStatus.delivered,
      ),
    ],
    'conv-aurora': [
      Message(
        id: 'm20',
        conversationId: 'conv-aurora',
        senderId: '100001',
        content: '周末有空一起测试新群组功能吗？',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        direction: MessageDirection.outgoing,
        status: MessageStatus.delivered,
      ),
    ],
  };

  static List<Contact> contacts() => List.unmodifiable(_contacts);

  static List<Conversation> conversations() {
    return [
      Conversation(
        id: 'conv-lena',
        contact: _contacts[0],
        lastMessagePreview: '收到，记得演示一下多端在线状态同步 👌',
        lastTimestamp: _messages['conv-lena']!.last.timestamp,
        unreadCount: 2,
        isPinned: true,
      ),
      Conversation(
        id: 'conv-marcus',
        contact: _contacts[1],
        lastMessagePreview: '桌面端主题已经调好了，稍后发你设计稿。',
        lastTimestamp: _messages['conv-marcus']!.last.timestamp,
      ),
      Conversation(
        id: 'conv-aurora',
        contact: _contacts[2],
        lastMessagePreview: '周末有空一起测试新群组功能吗？',
        lastTimestamp: _messages['conv-aurora']!.last.timestamp,
        unreadCount: 0,
      ),
    ];
  }

  static List<Message> messagesFor(String conversationId) {
    return List.unmodifiable(
      (_messages[conversationId] ?? const <Message>[])
          .map((message) => message.copyWith()),
    );
  }

  static Contact? contactById(String id) {
    return _contacts.firstWhere((contact) => contact.id == id,
        orElse: () => const Contact(
              id: 'temp',
              displayName: '新联系人',
              description: '等待同步',
            ));
  }

  static Conversation conversationForContact(Contact contact) {
    return Conversation(
      id: 'conv-${contact.id}',
      contact: contact,
      lastMessagePreview: '与 ${contact.displayName} 的安全会话已建立',
      lastTimestamp: DateTime.now(),
      unreadCount: 0,
    );
  }

  static Message incomingMessage(String conversationId, Contact contact) {
    final random = Random();
    final examples = [
      '我刚更新了头像，桌面端那边能立即同步吗？',
      '上线后记得邀请我体验群组频道～',
      '这条消息是从热友服务模拟推送的。',
      '安全提醒：请定期更新你的登录密码。',
    ];
    return Message(
      id: 'auto-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: contact.id,
      content: examples[random.nextInt(examples.length)],
      timestamp: DateTime.now(),
      direction: MessageDirection.incoming,
      status: MessageStatus.delivered,
    );
  }
}
