import 'dart:async';
import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/core/session/session_event.dart';
import 'package:im_client/core/socket/socket_manager.dart';
import 'package:im_client/core/storage/messages/friend_message_entity.dart';
import 'package:im_client/core/storage/messages/message_status.dart';
import 'package:im_client/core/storage/messages/voice_message_entity.dart';
import 'package:im_client/features/chat/data/message_repository.dart';
import 'package:im_client/features/debug/debug_dashboard_page.dart';
import 'package:im_client/gen/api/auth.pb.dart';
import 'package:im_client/gen/api/socket.pb.dart' as socketpb;

enum _SidebarView { contacts, voice, messages, settings }

class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({
    super.key,
    required this.session,
    required this.account,
    required this.userId,
    required this.deviceId,
    required this.deviceType,
  });

  final LoginResponse session;
  final String account;
  final int userId;
  final String deviceId;
  final int deviceType;

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  int? _selectedFriendId;
  StreamSubscription<socketpb.ServerMsg>? _socketSubscription;
  String _socketStatus = '未连接';
  late final SocketManager _socketManager;
  late final MessageRepository _messageRepository;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  _SidebarView _sidebarView = _SidebarView.contacts;
  int? _selectedVoiceMessageId;
  bool _isConnecting = false;
  bool _isShuttingDown = false;
  bool _kickDialogVisible = false;

  void _selectConversation(int friendId) {
    if (_selectedFriendId == friendId) {
      return;
    }
    setState(() {
      _selectedFriendId = friendId;
    });
  }

  void _changeSidebarView(_SidebarView view) {
    if (_sidebarView == view) {
      return;
    }
    setState(() {
      _sidebarView = view;
    });
  }

  void _selectVoiceMessage(int messageId) {
    if (_selectedVoiceMessageId == messageId) {
      return;
    }
    setState(() {
      _selectedVoiceMessageId = messageId;
    });
  }

  @override
  void initState() {
    super.initState();
    _socketManager = ref.read(socketManagerProvider);
    _messageRepository = ref.read(messageRepositoryProvider);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    _socketSubscription = _socketManager.messages.listen(
      (msg) async {
        await _messageRepository.handleIncomingMessage(
          msg,
          ownerId: widget.userId,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          final kindName = msg.kind.name;
          _socketStatus = '收到 $kindName (#${msg.id})';
        });
      },
      onError: (error) => _handleSocketTermination(error: error),
      onDone: () => _handleSocketTermination(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectSocket();
    });
  }

  Future<void> _connectSocket({bool isRetry = false}) async {
    if (!mounted || _isConnecting || _isShuttingDown) {
      return;
    }
    final socketAddr = widget.session.socketAddr;
    if (socketAddr.isEmpty) {
      setState(() {
        _socketStatus = '无可用 socket 节点';
      });
      return;
    }
    _isConnecting = true;
    setState(() {
      _socketStatus = isRetry ? '正在重连...' : '正在连接...';
    });
    try {
      await _socketManager.connect(
        address: socketAddr,
        userId: widget.userId,
        deviceType: widget.deviceType,
        deviceId: widget.deviceId,
        token: widget.session.token,
        resumeAckId: null,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        final userLabel = widget.account.isNotEmpty
            ? widget.account
            : '用户${widget.userId}';
        _socketStatus = '已连接 $socketAddr · $userLabel';
      });
    } on SocketConnectionException catch (err) {
      if (mounted) {
        setState(() {
          _socketStatus = '连接失败: ${err.message}';
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _socketStatus = '连接失败: $err';
        });
      }
    } finally {
      _isConnecting = false;
    }
  }

  void _handleSocketTermination({Object? error}) {
    if (_isShuttingDown || !mounted) {
      return;
    }
    setState(() {
      _socketStatus = error == null ? '连接已断开，准备重连' : '连接错误: $error';
    });
    _triggerReconnect();
  }

  void _triggerReconnect() {
    if (!mounted || _isConnecting || _isShuttingDown) {
      return;
    }
    unawaited(_connectSocket(isRetry: true));
  }

  @override
  void dispose() {
    _isShuttingDown = true;
    _socketSubscription?.cancel();
    _socketManager.disconnect();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showKickedDialog(SessionEvent event) async {
    if (_kickDialogVisible || !mounted) {
      return;
    }
    _kickDialogVisible = true;
    _isShuttingDown = true;
    final notifier = ref.read(sessionEventProvider.notifier);
    final message = event.message?.isNotEmpty == true
        ? event.message!
        : '你的账户已在另一台相同类型的设备上登录';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('账号异地登录'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    notifier.clear();
    await _socketManager.disconnect();
    _kickDialogVisible = false;
    if (kIsWeb) {
      return;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = ref.watch(messageRepositoryProvider);
    Widget content;
    switch (_sidebarView) {
      case _SidebarView.contacts:
        content = _buildConversationPage(
          context,
          theme,
          repository,
          title: '联系人',
          searchHint: '搜索联系人',
          emptyBuilder: (_) => const _EmptyHint(),
          trailingBuilder: (ctx) => IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: '添加好友',
            onPressed: () => _showAddFriendDialog(ctx),
          ),
        );
        break;
      case _SidebarView.voice:
        content = _buildVoiceLayout(context, theme, repository);
        break;
      case _SidebarView.messages:
        content = _buildConversationPage(
          context,
          theme,
          repository,
          title: '消息',
          searchHint: '搜索消息',
          emptyBuilder: (_) => const _MessagesEmptyHint(),
          trailingBuilder: (ctx) => IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: '新聊天',
            onPressed: () {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(const SnackBar(content: Text('聊天功能建设中')));
            },
          ),
        );
        break;
      case _SidebarView.settings:
        content = _buildSettingsPage(context, theme);
        break;
    }
    ref.listen<SessionEvent?>(sessionEventProvider, (previous, next) {
      if (!mounted || next == null) {
        return;
      }
      if (next.type == SessionEventType.kicked) {
        unawaited(_showKickedDialog(next));
      }
    });
    return KeyedSubtree(key: ValueKey(_sidebarView), child: content);
  }

  List<_FriendConversation> _groupByFriend(List<FriendMessageEntity> messages) {
    final latest = <int, FriendMessageEntity>{};
    for (final msg in messages) {
      final existing = latest[msg.friendId];
      if (existing == null || msg.timestamp > existing.timestamp) {
        latest[msg.friendId] = msg;
      }
    }
    final list = latest.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list.map(_toConversation).toList();
  }

  List<_FriendConversation> _filterConversations(
    List<_FriendConversation> conversations,
  ) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }
    final query = _searchQuery.toLowerCase();
    return conversations
        .where(
          (conv) =>
              conv.title.toLowerCase().contains(query) ||
              conv.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  _FriendConversation _toConversation(FriendMessageEntity entity) {
    final dt = DateTime.fromMillisecondsSinceEpoch(entity.timestamp).toLocal();
    final title = '好友 #${entity.friendId}';
    final subtitle = entity.textPreview?.isNotEmpty == true
        ? entity.textPreview!
        : '[${socketpb.MsgKind.valueOf(entity.kind)?.name ?? '消息'}]';
    return _FriendConversation(
      friendId: entity.friendId,
      title: title,
      subtitle: subtitle,
      timeLabel: _formatListTileTime(dt),
      timestamp: entity.timestamp,
    );
  }

  Widget _buildVoiceLayout(
    BuildContext context,
    ThemeData theme,
    MessageRepository repository,
  ) {
    return StreamBuilder<List<VoiceMessageEntity>>(
      stream: repository.watchVoiceMessages(ownerId: widget.userId),
      builder: (context, snapshot) {
        final calls = snapshot.data ?? const [];
        final sorted = List<VoiceMessageEntity>.from(calls)
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (sorted.isNotEmpty &&
            (_selectedVoiceMessageId == null ||
                !sorted.any(
                  (call) => call.messageId == _selectedVoiceMessageId,
                ))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedVoiceMessageId = sorted.first.messageId;
            });
          });
        }

        VoiceMessageEntity? selectedCall;
        final currentSelectedId = _selectedVoiceMessageId;
        if (currentSelectedId != null) {
          for (final call in sorted) {
            if (call.messageId == currentSelectedId) {
              selectedCall = call;
              break;
            }
          }
        }
        selectedCall ??= sorted.isNotEmpty ? sorted.first : null;

        final sidebarWidth = MediaQuery.of(context).size.width >= 900
            ? 320.0
            : 280.0;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Row(
            children: [
              Container(
                width: sidebarWidth,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              '最近通话',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: sorted.isEmpty ? null : () {},
                              child: const Text('编辑'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: OutlinedButton.icon(
                          onPressed: () => _showCreateCallDialog(
                            context,
                            theme,
                            repository,
                            sorted,
                          ),
                          icon: const Icon(Icons.add_call),
                          label: const Text('创建新通话'),
                        ),
                      ),
                      Expanded(
                        child: sorted.isEmpty
                            ? const _VoiceEmptyHint()
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                itemCount: sorted.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  final call = sorted[index];
                                  final title = _voiceEntryTitle(call);
                                  final statusLabel = _voiceListStatus(call);
                                  final timeLabel = _formatCallListTime(
                                    call.timestamp,
                                  );
                                  final iconData = _voiceDirectionIcon(call);
                                  final iconColor = _voiceDirectionColor(
                                    theme,
                                    call,
                                  );
                                  return _VoiceCallTile(
                                    title: title,
                                    subtitle: statusLabel,
                                    timeLabel: timeLabel,
                                    icon: iconData,
                                    iconColor: iconColor,
                                    isSelected:
                                        call.messageId ==
                                        _selectedVoiceMessageId,
                                    onTap: () =>
                                        _selectVoiceMessage(call.messageId),
                                  );
                                },
                              ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: _SidebarBottomActions(
                            currentView: _sidebarView,
                            onSelect: _changeSidebarView,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: _buildVoiceDetailPane(context, theme, selectedCall),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateCallDialog(
    BuildContext context,
    ThemeData theme,
    MessageRepository repository,
    List<VoiceMessageEntity> history,
  ) async {
    final candidates = await _collectCallCandidates(
      repository: repository,
      history: history,
    );
    if (!mounted) return;
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂无可呼叫的联系人')));
      return;
    }

    final candidateMap = {for (final item in candidates) item.key: item};
    final frequentKeys = <String>[];
    final seenFrequent = <String>{};
    for (final call in history) {
      final key = _callCandidateKey(call.isGroup, call.conversationId);
      if (candidateMap.containsKey(key) && seenFrequent.add(key)) {
        frequentKeys.add(key);
        if (frequentKeys.length >= 6) {
          break;
        }
      }
    }

    final searchController = TextEditingController();
    final selectedKeys = <String>{};

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            void toggleSelection(String key) {
              setState(() {
                if (!selectedKeys.add(key)) {
                  selectedKeys.remove(key);
                }
              });
            }

            final filter = searchController.text.trim().toLowerCase();
            final filteredCandidates = filter.isEmpty
                ? candidates
                : candidates
                      .where(
                        (c) =>
                            c.title.toLowerCase().contains(filter) ||
                            c.subtitle.toLowerCase().contains(filter),
                      )
                      .toList();

            final frequentCandidates = filter.isEmpty
                ? [
                    for (final key in frequentKeys)
                      if (candidateMap[key] != null) candidateMap[key]!,
                  ]
                : const <_CallCandidate>[];

            final listCandidates = filter.isEmpty
                ? candidates
                      .where((c) => !frequentKeys.contains(c.key))
                      .toList()
                : filteredCandidates;

            final selectedCandidates = [
              for (final key in selectedKeys)
                if (candidateMap[key] != null) candidateMap[key]!,
            ];

            final canStartCall = selectedKeys.isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('创建通话'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                  });
                                },
                              ),
                        hintText: '搜索联系人名称',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (selectedCandidates.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final entry in selectedCandidates)
                            InputChip(
                              label: Text(entry.title),
                              onDeleted: () => setState(() {
                                selectedKeys.remove(entry.key);
                              }),
                            ),
                        ],
                      ),
                    ],
                    if (filter.isEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        '常用联系人',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (frequentCandidates.isEmpty)
                        Text(
                          '暂无常用联系人',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        ...frequentCandidates.map(
                          (candidate) => _CallCandidateTile(
                            candidate: candidate,
                            isSelected: selectedKeys.contains(candidate.key),
                            onTap: () => toggleSelection(candidate.key),
                          ),
                        ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('通话链接功能建设中')),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(Icons.link_rounded),
                          title: const Text('生成通话链接'),
                          subtitle: const Text('分享邀请链接以开始通话'),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 320,
                      child: listCandidates.isEmpty
                          ? Center(
                              child: Text(
                                filter.isEmpty ? '暂无联系人' : '未找到匹配的联系人',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: listCandidates.length,
                              itemBuilder: (context, index) {
                                final candidate = listCandidates[index];
                                final isSelected = selectedKeys.contains(
                                  candidate.key,
                                );
                                return _CallCandidateTile(
                                  candidate: candidate,
                                  isSelected: isSelected,
                                  onTap: () => toggleSelection(candidate.key),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: canStartCall
                      ? () {
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('通话功能建设中')),
                          );
                        }
                      : null,
                  child: const Text('开始通话'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<_CallCandidate>> _collectCallCandidates({
    required MessageRepository repository,
    required List<VoiceMessageEntity> history,
  }) async {
    final map = <String, _CallCandidate>{};

    void addCandidate({
      required bool isGroup,
      required int conversationId,
      required String title,
      required String subtitle,
    }) {
      final key = _callCandidateKey(isGroup, conversationId);
      map.putIfAbsent(
        key,
        () => _CallCandidate(
          key: key,
          title: title,
          subtitle: subtitle,
          isGroup: isGroup,
          conversationId: conversationId,
        ),
      );
    }

    for (final call in history) {
      final title = _voiceEntryTitle(call);
      final subtitle = _voiceListStatus(call);
      addCandidate(
        isGroup: call.isGroup,
        conversationId: call.conversationId,
        title: title,
        subtitle: subtitle,
      );
    }

    try {
      final friendMessages = await repository
          .watchFriendMessages(ownerId: widget.userId)
          .first;
      final List<_FriendConversation> conversations = _groupByFriend(
        friendMessages,
      );
      for (final conversation in conversations) {
        addCandidate(
          isGroup: false,
          conversationId: conversation.friendId,
          title: conversation.title,
          subtitle: conversation.subtitle,
        );
      }
    } catch (_) {
      // 忽略加载失败，保持已有候选项。
    }

    final list = map.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  Widget _buildVoiceDetailPane(
    BuildContext context,
    ThemeData theme,
    VoiceMessageEntity? call,
  ) {
    if (call == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mic_none_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text('请选择通话记录', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final contactName = _voiceEntryTitle(call);
    final statusLabel = _voiceDetailStatus(call);
    final callTimeLabel = _formatCallDetailTime(call.timestamp);
    final durationLabel = _formatVoiceDuration(call.durationSeconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.16),
                child: Text(
                  contactName.characters.first.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(statusLabel, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      callTimeLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('语音通话功能建设中')));
                },
                icon: const Icon(Icons.call_rounded),
                label: const Text('语音通话'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('视频通话功能建设中')));
                },
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('视频通话'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('消息功能建设中')));
                },
                icon: const Icon(Icons.message_rounded),
                label: const Text('发送消息'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VoiceDetailRow(
                icon: Icons.access_time_rounded,
                label: '通话时长',
                value: durationLabel.isEmpty ? '未知' : durationLabel,
              ),
              const SizedBox(height: 12),
              _VoiceDetailRow(
                icon: Icons.alternate_email_rounded,
                label: call.isGroup ? '群组 ID' : '好友 ID',
                value: call.conversationId.toString(),
              ),
              const SizedBox(height: 12),
              _VoiceDetailRow(
                icon: Icons.person_outline,
                label: '发起人',
                value: call.senderId.toString(),
              ),
              if (call.receiverId != null) ...[
                const SizedBox(height: 12),
                _VoiceDetailRow(
                  icon: Icons.call_received_rounded,
                  label: '接收人',
                  value: call.receiverId!.toString(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationPage(
    BuildContext context,
    ThemeData theme,
    MessageRepository repository, {
    required String title,
    required String searchHint,
    required Widget Function(BuildContext context) emptyBuilder,
    required Widget Function(BuildContext context) trailingBuilder,
  }) {
    return StreamBuilder<List<FriendMessageEntity>>(
      stream: repository.watchFriendMessages(ownerId: widget.userId),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? const [];
        final conversations = _groupByFriend(messages);
        final filteredConversations = _filterConversations(conversations);

        if (filteredConversations.isNotEmpty &&
            (_selectedFriendId == null ||
                !filteredConversations.any(
                  (conv) => conv.friendId == _selectedFriendId,
                ))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedFriendId = filteredConversations.first.friendId;
            });
          });
        }

        final currentFriendId =
            _selectedFriendId ??
            (filteredConversations.isNotEmpty
                ? filteredConversations.first.friendId
                : null);
        final currentMessages = currentFriendId == null
            ? const <FriendMessageEntity>[]
            : (messages.where((msg) => msg.friendId == currentFriendId).toList()
                ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));

        final currentConversation = currentFriendId == null
            ? null
            : filteredConversations.firstWhere(
                (conv) => conv.friendId == currentFriendId,
                orElse: () => conversations.firstWhere(
                  (conv) => conv.friendId == currentFriendId,
                  orElse: () =>
                      _FriendConversation.placeholder(currentFriendId),
                ),
              );

        final sidebarWidth = MediaQuery.of(context).size.width >= 900
            ? 320.0
            : 280.0;
        final emptyWidget = emptyBuilder(context);
        final trailing = trailingBuilder(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Row(
            children: [
              Container(
                width: sidebarWidth,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SidebarTopActions(
                          title: title,
                          onSort: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('排序功能建设中')),
                            );
                          },
                          trailing: trailing,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: searchHint,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: filteredConversations.isEmpty
                                    ? emptyWidget
                                    : ListView.separated(
                                        itemCount: filteredConversations.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 4),
                                        itemBuilder: (context, index) {
                                          final conversation =
                                              filteredConversations[index];
                                          return _ConversationTile(
                                            title: conversation.title,
                                            snippet: conversation.subtitle,
                                            timeLabel: conversation.timeLabel,
                                            unreadCount: 0,
                                            isSelected:
                                                conversation.friendId ==
                                                currentFriendId,
                                            onTap: () => _selectConversation(
                                              conversation.friendId,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: _SidebarBottomActions(
                            currentView: _sidebarView,
                            onSelect: _changeSidebarView,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ChatToolbar(
                        title: currentConversation?.title ?? '选择会话',
                        subtitle: currentFriendId == null
                            ? _socketStatus
                            : currentConversation?.subtitle ?? _socketStatus,
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Container(
                          color: theme.colorScheme.background,
                          child: currentFriendId == null
                              ? const Center(child: Text('请选择会话'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  itemCount: currentMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = currentMessages[index];
                                    final isMine = message.isOutgoing;
                                    final alignment = isMine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft;
                                    final bubbleColor = isMine
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceVariant
                                              .withOpacity(0.6);
                                    final textColor = isMine
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface;
                                    return Align(
                                      alignment: alignment,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth: 520,
                                        ),
                                        decoration: BoxDecoration(
                                          color: bubbleColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message.textPreview ??
                                                  '[${socketpb.MsgKind.valueOf(message.kind)?.name ?? '消息'}]',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(color: textColor),
                                            ),
                                            const SizedBox(height: 4),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                _formatBubbleTime(
                                                  message.timestamp,
                                                ),
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: textColor
                                                          .withOpacity(0.75),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const Divider(height: 1),
                      _MessageComposer(
                        enabled: currentFriendId != null,
                        onSend: (text) {
                          if (currentFriendId == null) {
                            return;
                          }
                          unawaited(
                            _messageRepository.queueFriendText(
                              text,
                              ownerId: widget.userId,
                              friendId: currentFriendId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsPage(BuildContext context, ThemeData theme) {
    final sidebarWidth = MediaQuery.of(context).size.width >= 900
        ? 320.0
        : 280.0;
    final tiles = <_SettingsTile>[
      _SettingsTile(
        icon: Icons.person_outline,
        title: '账号与安全',
        subtitle: '账号信息、密码与偏好设置',
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('账号设置功能建设中')));
        },
      ),
      _SettingsTile(
        icon: Icons.notifications_outlined,
        title: '通知偏好',
        subtitle: '消息提醒、声音与桌面通知',
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('通知设置功能建设中')));
        },
      ),
      _SettingsTile(
        icon: Icons.storage_rounded,
        title: '存储管理',
        subtitle: '缓存占用、媒体文件与数据导出',
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('存储管理功能建设中')));
        },
      ),
      _SettingsTile(
        icon: Icons.bug_report_outlined,
        title: '调试工具',
        subtitle: '查看/管理 Isar 数据与实时日志',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const DebugDashboardPage()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          Container(
            width: sidebarWidth,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '设置中心',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.settings_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      children: [
                        _SettingsCategoryCard(
                          title: '常规设置',
                          child: Column(
                            children: [
                              const _SettingsSummaryRow(
                                label: '应用版本',
                                value: '1.0.0',
                              ),
                              const SizedBox(height: 4),
                              _SettingsSummaryRow(
                                label: '上次同步',
                                value: _formatBubbleTime(
                                  DateTime.now().millisecondsSinceEpoch,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsCategoryCard(
                          title: '操作',
                          child: Column(
                            children: [
                              for (var i = 0; i < tiles.length; i++)
                                Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(tiles[i].icon),
                                      title: Text(tiles[i].title),
                                      subtitle: Text(tiles[i].subtitle),
                                      onTap: tiles[i].onTap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    if (i != tiles.length - 1)
                                      const Divider(height: 1),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: _SidebarBottomActions(
                        currentView: _sidebarView,
                        onSelect: _changeSidebarView,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                    children: [
                      Text(
                        '应用设置',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '管理账号信息、通知偏好、存储使用情况，以及开发调试工具等。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < tiles.length; i++)
                              Column(
                                children: [
                                  ListTile(
                                    leading: Icon(tiles[i].icon),
                                    title: Text(tiles[i].title),
                                    subtitle: Text(tiles[i].subtitle),
                                    onTap: tiles[i].onTap,
                                  ),
                                  if (i != tiles.length - 1)
                                    const Divider(height: 1),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFriendDialog(BuildContext context) async {
    final controller = TextEditingController();
    var isLoading = false;
    UserProfile? profile;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> search() async {
              final query = controller.text.trim();
              if (query.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入查询内容')));
                return;
              }
              setState(() {
                isLoading = true;
                profile = null;
                errorText = null;
              });

              final detected = _detectSearchType(query);
              final searchType = _grpcSearchTypeFor(detected);
              final api = ref.read(authApiClientProvider);
              try {
                final resp = await api.searchUser(searchType, query);
                setState(() {
                  isLoading = false;
                  profile = resp.user;
                  if (profile == null) {
                    errorText = '未找到相关用户';
                  }
                });
              } catch (err) {
                setState(() {
                  isLoading = false;
                  errorText = '搜索失败: $err';
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('添加好友'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      onSubmitted: (_) => search(),
                      decoration: const InputDecoration(
                        hintText: '请输入用户名、邮箱或电话号码',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (!isLoading && errorText != null)
                      Text(
                        errorText!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    if (!isLoading && profile != null)
                      _UserSearchResultCard(
                        profile: profile!,
                        onApply: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已向 ${profile!.username} 发送好友申请'),
                            ),
                          );
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: isLoading ? null : search,
                  child: const Text('搜索'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String _formatBubbleTime(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final now = DateTime.now();
  if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String _formatListTileTime(DateTime dt) {
  final now = DateTime.now();
  if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  if (now.year == dt.year) {
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _SidebarTopActions extends StatelessWidget {
  const _SidebarTopActions({
    required this.title,
    required this.onSort,
    this.trailing,
  });

  final String title;
  final VoidCallback onSort;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingWidget = trailing ?? const SizedBox(width: 48, height: 48);
    return Row(
      children: [
        Tooltip(
          message: '排序',
          child: IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: onSort,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 48, height: 48, child: Center(child: trailingWidget)),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('暂无联系人', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MessagesEmptyHint extends StatelessWidget {
  const _MessagesEmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('暂无会话', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _VoiceEmptyHint extends StatelessWidget {
  const _VoiceEmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('暂无通话记录', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _CallCandidateTile extends StatelessWidget {
  const _CallCandidateTile({
    required this.candidate,
    required this.isSelected,
    required this.onTap,
  });

  final _CallCandidate candidate;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = candidate.isGroup
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withOpacity(0.15),
            child: Text(
              candidate.title.characters.first.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: avatarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(candidate.title, style: theme.textTheme.bodyLarge),
          subtitle: Text(
            candidate.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          trailing: Icon(
            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _VoiceCallTile extends StatelessWidget {
  const _VoiceCallTile({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isSelected
        ? theme.colorScheme.surface.withOpacity(0.9)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          child: Text(
            title.characters.first.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Text(
          timeLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _VoiceDetailRow extends StatelessWidget {
  const _VoiceDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _SidebarBottomActions extends StatelessWidget {
  const _SidebarBottomActions({
    required this.currentView,
    required this.onSelect,
  });

  final _SidebarView currentView;
  final void Function(_SidebarView view) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _SidebarBottomActionButton(
            icon: Icons.people_alt_outlined,
            label: '联系人',
            isActive: currentView == _SidebarView.contacts,
            onTap: () => onSelect(_SidebarView.contacts),
          ),
          _SidebarBottomActionButton(
            icon: Icons.mic_none_outlined,
            label: '通话',
            isActive: currentView == _SidebarView.voice,
            onTap: () => onSelect(_SidebarView.voice),
          ),
          _SidebarBottomActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: '消息',
            isActive: currentView == _SidebarView.messages,
            onTap: () => onSelect(_SidebarView.messages),
          ),
          _SidebarBottomActionButton(
            icon: Icons.settings_outlined,
            label: '设置',
            isActive: currentView == _SidebarView.settings,
            onTap: () => onSelect(_SidebarView.settings),
          ),
        ],
      ),
    );
  }
}

class _FriendConversation {
  _FriendConversation({
    required this.friendId,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.timestamp,
  });

  final int friendId;
  final String title;
  final String subtitle;
  final String timeLabel;
  final int timestamp;

  factory _FriendConversation.placeholder(int friendId) {
    final dt = DateTime.now();
    return _FriendConversation(
      friendId: friendId,
      title: '好友 #$friendId',
      subtitle: '暂无消息',
      timeLabel: _formatListTileTime(dt),
      timestamp: dt.millisecondsSinceEpoch,
    );
  }
}

enum _FriendSearchType { username, phone, email }

_FriendSearchType _detectSearchType(String query) {
  final trimmed = query.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final phoneRegex = RegExp(r'^\+?\d[\d\s-]{5,}$');
  if (emailRegex.hasMatch(trimmed)) {
    return _FriendSearchType.email;
  }
  if (phoneRegex.hasMatch(trimmed)) {
    return _FriendSearchType.phone;
  }
  return _FriendSearchType.username;
}

UserSearchType _grpcSearchTypeFor(_FriendSearchType type) {
  switch (type) {
    case _FriendSearchType.phone:
      return UserSearchType.USER_SEARCH_PHONE;
    case _FriendSearchType.email:
      return UserSearchType.USER_SEARCH_EMAIL;
    case _FriendSearchType.username:
      return UserSearchType.USER_SEARCH_USERNAME;
  }
}

class _UserSearchResultCard extends StatelessWidget {
  const _UserSearchResultCard({required this.profile, required this.onApply});

  final UserProfile profile;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = profile.username.isNotEmpty
        ? profile.username.characters.first
        : '?';
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, child: Text(initials.toUpperCase())),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('用户ID: ${profile.userId}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.hasEmail() && profile.email.isNotEmpty)
              Text('邮箱: ${profile.email}'),
            if (profile.hasPhone() && profile.phone.isNotEmpty)
              Text('电话: ${profile.phone}'),
            Text(
              '签名: ${profile.hasSignature() && profile.signature.isNotEmpty ? profile.signature : '暂无'}',
            ),
            Text(
              '地区: ${profile.hasRegion() && profile.region.isNotEmpty ? profile.region : '未知'}',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('申请好友'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarBottomActionButton extends StatelessWidget {
  const _SidebarBottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Icon(
              icon,
              size: 24,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.title,
    required this.snippet,
    required this.timeLabel,
    required this.unreadCount,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String snippet;
  final String timeLabel;
  final int unreadCount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.12)
        : theme.colorScheme.surfaceVariant.withOpacity(0.3);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
          child: Text(
            title.characters.first.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(snippet, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeLabel, style: theme.textTheme.labelSmall),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatToolbar extends StatelessWidget {
  const _ChatToolbar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(
              Icons.groups_2_outlined,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (kDebugMode)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DebugDashboardPage(),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Debug'),
            ),
          if (kDebugMode) const SizedBox(width: 8),
          IconButton(
            tooltip: '搜索',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '更多',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.onSend, required this.enabled});

  final ValueChanged<String>? onSend;
  final bool enabled;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: '输入消息，按回车发送',
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) {
                  return;
                }
                widget.onSend?.call(value.trim());
                _controller.clear();
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: widget.enabled
                ? () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) {
                      return;
                    }
                    widget.onSend?.call(text);
                    _controller.clear();
                  }
                : null,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('发送'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _SettingsCategoryCard extends StatelessWidget {
  const _SettingsCategoryCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsSummaryRow extends StatelessWidget {
  const _SettingsSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CallCandidate {
  const _CallCandidate({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.isGroup,
    required this.conversationId,
  });

  final String key;
  final String title;
  final String subtitle;
  final bool isGroup;
  final int conversationId;
}

String _callCandidateKey(bool isGroup, int conversationId) =>
    '${isGroup ? 'g' : 'u'}_$conversationId';

String _voiceEntryTitle(VoiceMessageEntity call) {
  return call.isGroup
      ? '群组 #${call.conversationId}'
      : '好友 #${call.conversationId}';
}

bool _isMissedIncoming(VoiceMessageEntity call) {
  return !call.isOutgoing && call.status == MessageDeliveryStatus.failed;
}

bool _isFailedOutgoing(VoiceMessageEntity call) {
  return call.isOutgoing && call.status == MessageDeliveryStatus.failed;
}

String _voiceListStatus(VoiceMessageEntity call) {
  if (_isMissedIncoming(call)) {
    return '未接来电';
  }
  if (_isFailedOutgoing(call)) {
    return '未拨通';
  }
  final direction = call.isOutgoing ? '呼出' : '来电';
  final duration = _formatVoiceDuration(call.durationSeconds);
  return duration.isEmpty ? direction : '$direction · $duration';
}

String _voiceDetailStatus(VoiceMessageEntity call) {
  if (_isMissedIncoming(call)) {
    return '未接来电';
  }
  if (_isFailedOutgoing(call)) {
    return '未拨通';
  }
  final prefix = call.isOutgoing ? '呼出通话' : '接听来电';
  final duration = _formatVoiceDuration(call.durationSeconds);
  return duration.isEmpty ? prefix : '$prefix · $duration';
}

IconData _voiceDirectionIcon(VoiceMessageEntity call) {
  if (_isMissedIncoming(call)) {
    return Icons.call_missed_rounded;
  }
  if (_isFailedOutgoing(call)) {
    return Icons.call_missed_outgoing_rounded;
  }
  return call.isOutgoing
      ? Icons.call_made_rounded
      : Icons.call_received_rounded;
}

Color _voiceDirectionColor(ThemeData theme, VoiceMessageEntity call) {
  if (call.status == MessageDeliveryStatus.failed) {
    return theme.colorScheme.error;
  }
  return call.isOutgoing
      ? theme.colorScheme.primary
      : theme.colorScheme.secondary;
}

String _formatCallListTime(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final now = DateTime.now();
  final sameDay =
      now.year == dt.year && now.month == dt.month && now.day == dt.day;
  if (sameDay) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  final sameYear = now.year == dt.year;
  if (sameYear) {
    return '${dt.month}/${dt.day}';
  }
  return '${dt.year}/${dt.month}/${dt.day}';
}

String _formatCallDetailTime(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final year = dt.year.toString();
  final month = dt.month.toString().padLeft(2, '0');
  final day = dt.day.toString().padLeft(2, '0');
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

String _formatVoiceDuration(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return '';
  }
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  if (minutes == 0) {
    return '${remaining}秒';
  }
  return '${minutes}分${remaining.toString().padLeft(2, '0')}秒';
}
