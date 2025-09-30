import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  final List<String> singleConversations = List.generate(5, (i) => '单聊 ${i + 1}');
  final List<String> groupConversations = List.generate(5, (i) => '群聊 ${i + 1}');
  bool isGroupTab = false;

  @override
  Widget build(BuildContext context) {
    final currentList = isGroupTab ? groupConversations : singleConversations;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            onPointerMove: (event) {
              if (_dragging) {
                setState(() {
                  leftPanelWidth += event.delta.dx;
                  leftPanelWidth = leftPanelWidth.clamp(minWidth, maxWidth);
                });
              }
            },
            child: Row(
              children: [
                Container(
                  width: leftPanelWidth,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F9FC),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text('会话列表', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ToggleButtons(
                        isSelected: [!isGroupTab, isGroupTab],
                        onPressed: (index) => setState(() => isGroupTab = index == 1),
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.indigo,
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("单聊")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("群聊")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            final isSelected = selectedIndex == index;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: Colors.indigo[100],
                              leading: CircleAvatar(child: Icon(isGroupTab ? Icons.group : Icons.person)),
                              title: Text(currentList[index]),
                              subtitle: const Text('最近消息...'),
                              onTap: () => setState(() => selectedIndex = index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) => setState(() => _dragging = true),
                  onHorizontalDragEnd: (_) => setState(() => _dragging = false),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(
                      width: 6,
                      color: _dragging ? Colors.indigo.withOpacity(0.4) : Colors.transparent,
                    ),
                  ),
                ),
                const Expanded(
                  child: ChatMainArea(),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatMainArea extends StatelessWidget {
  const ChatMainArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            border: const Border(bottom: BorderSide(color: Colors.black12)),
          ),
          width: double.infinity,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('聊天窗口 - 会话名称', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.more_vert)
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Align(
                alignment: Alignment.centerLeft,
                child: ChatBubble(text: '你好！'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ChatBubble(text: '你好，有什么可以帮忙的吗？', isSelf: true),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ChatBubble(text: '我想了解一下您的产品。'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ChatBubble(text: '当然，具体您对哪方面感兴趣？', isSelf: true),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.emoji_emotions_outlined), onPressed: () {}),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "输入消息...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
              IconButton(icon: const Icon(Icons.send), onPressed: () {}),
            ],
          ),
        )
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSelf;

  const ChatBubble({super.key, required this.text, this.isSelf = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: isSelf ? Colors.indigo[200] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }
}