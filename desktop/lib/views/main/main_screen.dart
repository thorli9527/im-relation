// lib/views/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/shared/constants.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ContactsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ResizableChatLayout();
  }
}

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '联系人列表',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '设置',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ResizableChatLayout extends StatefulWidget {
  const ResizableChatLayout({super.key});

  @override
  State<ResizableChatLayout> createState() => _ResizableChatLayoutState();
}

class _ResizableChatLayoutState extends State<ResizableChatLayout> {
  double leftPanelWidth = 260;
  double minWidth = 200;
  double maxWidth = 400;
  bool _dragging = false;
  int selectedIndex = 0;

  final List<String> conversations = List.generate(20, (i) => '会话 ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧会话列表
        SizedBox(
            width: leftPanelWidth,
            child: Container(
              color: const Color.fromARGB(255, 240, 240, 240), // 添加浅灰色背景
              child: Column(
                children: [
                  // 会话列表标题和搜索框
                  Container(
                    padding: const EdgeInsets.only(
                        top: 30, left: 5, right: 5, bottom: 5),
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, size: 16),
                          onPressed: () {
                            // TODO: 添加你的逻辑
                          },
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '搜索',
                                prefixIcon: const Icon(Icons.search, size: 14),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 会话列表
                  Expanded(
                    child: ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              // 内容部分
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? kPrimaryColor.withAlpha(0x20)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    selected: isSelected,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(
                                      conversations[index],
                                      style: TextStyle(
                                        fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? kPrimaryColor : null,
                                      ),
                                    ),
                                    subtitle: const Text('最近消息预览...'),
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),

        // 可拖动分隔条
        MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                leftPanelWidth += details.delta.dx;
                if (leftPanelWidth < minWidth) leftPanelWidth = minWidth;
                if (leftPanelWidth > maxWidth) leftPanelWidth = maxWidth;
              });
            },
            onHorizontalDragStart: (_) => setState(() => _dragging = true),
            onHorizontalDragEnd: (_) => setState(() => _dragging = false),
            child: Container(
              width: 2,
              color: _dragging
                  ? Colors.grey // 拖拽时显示灰色
                  : Colors.transparent,
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // 右侧聊天主窗口
        const Expanded(
          child: ChatDetailView(),
        ),
      ],
    );
  }
}

class ChatDetailView extends StatelessWidget {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 聊天标题栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.person),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '会话名称',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '在线',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.call),
              SizedBox(width: 10),
              Icon(Icons.videocam),
              SizedBox(width: 10),
              Icon(Icons.more_vert),
            ],
          ),
        ),

        // 消息区域
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: const [
              MessageBubble(
                text: "你好！",
                isSelf: false,
                time: "10:30",
              ),
              MessageBubble(
                text: "你好，有什么可以帮助你的吗？",
                isSelf: true,
                time: "10:31",
              ),
              MessageBubble(
                text: "我想了解一下你们的产品",
                isSelf: false,
                time: "10:32",
              ),
              MessageBubble(
                text: "当然，我们的产品具有以下特点...",
                isSelf: true,
                time: "10:33",
              ),
            ],
          ),
        ),

        // 输入区域
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "输入消息...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isSelf;
  final String time;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isSelf,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelf ? kPrimaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelf ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isSelf ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
