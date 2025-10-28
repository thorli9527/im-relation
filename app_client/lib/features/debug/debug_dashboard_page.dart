import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:im_client/core/logging/debug_log_buffer.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/core/storage/local_store.dart';

import 'isar_debug_defs.dart';

class DebugDashboardPage extends StatelessWidget {
  const DebugDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('调试工具平台'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '数据管理'),
              Tab(text: '日志查询'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DataManagementTab(), _LogViewerTab()],
        ),
      ),
    );
  }
}

class _DataManagementTab extends ConsumerStatefulWidget {
  const _DataManagementTab();

  @override
  ConsumerState<_DataManagementTab> createState() => _DataManagementTabState();
}

class _DataManagementTabState extends ConsumerState<_DataManagementTab> {
  int _reloadToken = 0;

  LocalStore get _store => ref.read(localStoreProvider);

  Isar get _isar => _store.isar;

  void _refresh() {
    if (!mounted) {
      return;
    }
    setState(() {
      _reloadToken += 1;
    });
  }

  Future<void> _clearCollection(IsarDebugCollection collection) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('清空 ${collection.name}?'),
        content: const Text('此操作会删除该集合下的所有数据且无法恢复，确认执行吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await collection.clear(_isar);
      _refresh();
    }
  }

  Future<void> _deleteRecord(
    IsarDebugCollection collection,
    dynamic record,
  ) async {
    final id = collection.idOf(record);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除 ${collection.name} #$id'),
        content: const Text('删除后数据将无法恢复，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await collection.delete(_isar, record);
      _refresh();
    }
  }

  Future<void> _openEditor({
    required IsarDebugCollection collection,
    required dynamic record,
    required bool isNew,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RecordEditorDialog(
        collection: collection,
        record: record,
        isNew: isNew,
      ),
    );
    if (saved == true) {
      await collection.save(_isar, record);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collections = buildIsarDebugCollections();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(collection.name),
            subtitle: Text('刷新次数：$_reloadToken'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              FutureBuilder<List<dynamic>>(
                future: collection.fetchAll(_isar),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '加载失败: ${snapshot.error}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }
                  final records = snapshot.data ?? const [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              final fresh = collection.createNew();
                              _openEditor(
                                collection: collection,
                                record: fresh,
                                isNew: true,
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('新增记录'),
                          ),
                          OutlinedButton.icon(
                            onPressed: records.isEmpty
                                ? null
                                : () => _clearCollection(collection),
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: const Text('清空集合'),
                          ),
                          TextButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('刷新'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (records.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('暂无数据'),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          separatorBuilder: (_, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final record = records[idx];
                            final id = collection.idOf(record);
                            final subtitle = _buildRecordSummary(
                              collection,
                              record,
                            );
                            return ListTile(
                              title: Text(collection.displayTitle(record)),
                              subtitle: subtitle.isEmpty
                                  ? null
                                  : Text(
                                      subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              leading: CircleAvatar(
                                child: Text(
                                  id?.toString() ?? '?',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: '编辑',
                                    onPressed: () => _openEditor(
                                      collection: collection,
                                      record: record,
                                      isNew: false,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: '删除',
                                    onPressed: () =>
                                        _deleteRecord(collection, record),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildRecordSummary(IsarDebugCollection collection, dynamic record) {
    final buffer = StringBuffer();
    for (final field in collection.fields) {
      final value = field.getValue(record);
      if (value == null || (value is String && value.isEmpty)) {
        continue;
      }
      buffer
        ..write(field.label)
        ..write(': ')
        ..write(formatDebugValue(field.type, value))
        ..write('  ');
      if (buffer.length > 160) {
        buffer.write('...');
        break;
      }
    }
    return buffer.toString().trim();
  }
}

class _LogViewerTab extends ConsumerStatefulWidget {
  const _LogViewerTab();

  @override
  ConsumerState<_LogViewerTab> createState() => _LogViewerTabState();
}

class _LogViewerTabState extends ConsumerState<_LogViewerTab> {
  final TextEditingController _searchController = TextEditingController();
  Level? _levelFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _setLevelFilter(Level? level) {
    if (!mounted) {
      return;
    }
    setState(() {
      _levelFilter = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    final buffer = ref.watch(debugLogBufferProvider);
    final query = _searchController.text.trim().toLowerCase();
    final levelFilter = _levelFilter;

    final filtered = buffer.records.where((record) {
      if (levelFilter != null && record.level != levelFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final message = record.message.toLowerCase();
      if (message.contains(query)) {
        return true;
      }
      for (final line in record.lines) {
        if (line.toLowerCase().contains(query)) {
          return true;
        }
      }
      return false;
    }).toList()..sort((a, b) => b.time.compareTo(a.time));

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: '搜索日志（内容、堆栈）',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<Level?>(
                value: levelFilter,
                onChanged: _setLevelFilter,
                hint: const Text('全部级别'),
                items: [
                  const DropdownMenuItem<Level?>(
                    value: null,
                    child: Text('全部级别'),
                  ),
                  for (final level in _availableLevels)
                    DropdownMenuItem<Level?>(
                      value: level,
                      child: Text(level.name.toUpperCase()),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: buffer.records.isEmpty ? null : buffer.clear,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('清空日志'),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('暂未捕获日志'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final record = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        leading: _LevelIndicator(level: record.level),
                        title: Text(
                          '[${record.level.name.toUpperCase()}] ${_formatTime(record.time)}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          record.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              record.lines.join('\n'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          if (record.stackTrace != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                record.stackTrace.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _copyRecord(record),
                              icon: const Icon(Icons.copy_rounded),
                              label: const Text('复制'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _copyRecord(DebugLogRecord record) {
    final buffer = StringBuffer()
      ..writeln(
        '[${record.level.name.toUpperCase()}] ${record.time.toIso8601String()}',
      )
      ..writeln(record.message);
    for (final line in record.lines) {
      buffer.writeln(line);
    }
    if (record.stackTrace != null) {
      buffer
        ..writeln('StackTrace:')
        ..writeln(record.stackTrace);
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('日志已复制到剪贴板')));
  }
}

class _LevelIndicator extends StatelessWidget {
  const _LevelIndicator({required this.level});

  final Level level;

  Color _colorForLevel(ColorScheme scheme) {
    if (level == Level.all || level == Level.off) {
      return scheme.outlineVariant;
    }
    if (level.value > Level.fatal.value && level.value < Level.off.value) {
      // Legacy 'nothing' level.
      return scheme.outlineVariant;
    }
    if (level.value >= Level.error.value) {
      return scheme.error;
    }
    if (level == Level.warning) {
      return scheme.tertiary;
    }
    if (level == Level.info) {
      return scheme.primary;
    }
    if (level == Level.debug) {
      return scheme.secondary;
    }
    if (level.value <= Level.trace.value) {
      // Covers trace and legacy verbose.
      return scheme.outline;
    }
    return scheme.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _colorForLevel(scheme);
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        level.name.substring(0, 1).toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  final second = time.second.toString().padLeft(2, '0');
  final millisecond = (time.millisecond ~/ 10).toString().padLeft(2, '0');
  return '$hour:$minute:$second.$millisecond';
}

const List<Level> _availableLevels = [
  Level.trace,
  Level.debug,
  Level.info,
  Level.warning,
  Level.error,
  Level.fatal,
  Level.all,
  Level.off,
];

class _RecordEditorDialog extends StatefulWidget {
  const _RecordEditorDialog({
    required this.collection,
    required this.record,
    required this.isNew,
  });

  final IsarDebugCollection collection;
  final dynamic record;
  final bool isNew;

  @override
  State<_RecordEditorDialog> createState() => _RecordEditorDialogState();
}

class _RecordEditorDialogState extends State<_RecordEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<_FieldBinding> _bindings;

  @override
  void initState() {
    super.initState();
    _bindings = widget.collection.fields
        .map((field) {
          final value = field.getValue(widget.record);
          if (field.type == DebugFieldType.boolean) {
            return _FieldBinding.boolField(
              field: field,
              controller: ValueNotifier<bool>(value == true),
            );
          }
          final controller = TextEditingController(
            text: formatDebugValue(field.type, value),
          );
          return _FieldBinding.textField(field: field, controller: controller);
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    for (final binding in _bindings) {
      binding.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      return;
    }
    for (final binding in _bindings) {
      final field = binding.field;
      if (!field.editable || field.setValue == null) {
        continue;
      }
      dynamic parsed;
      if (field.type == DebugFieldType.boolean) {
        parsed = binding.boolController?.value ?? false;
      } else {
        final raw = binding.textController?.text.trim() ?? '';
        parsed = _parseFieldValue(field, raw);
      }
      field.setValue!(widget.record, parsed);
    }
    form.save();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  dynamic _parseFieldValue(DebugFieldView field, String raw) {
    if (raw.isEmpty) {
      if (field.optional) {
        return null;
      }
    }
    switch (field.type) {
      case DebugFieldType.boolean:
        return raw == 'true';
      case DebugFieldType.int:
        if (raw.isEmpty && field.optional) {
          return null;
        }
        return int.parse(raw);
      case DebugFieldType.double:
        if (raw.isEmpty && field.optional) {
          return null;
        }
        return double.parse(raw);
      case DebugFieldType.dateTime:
        if (raw.isEmpty) {
          return null;
        }
        return DateTime.parse(raw);
      case DebugFieldType.bytes:
        final result = decodeBytesField(raw);
        if (result == null) {
          throw const FormatException('base64 解码失败');
        }
        return result;
      case DebugFieldType.string:
      case DebugFieldType.text:
        if (raw.isEmpty && field.optional) {
          return null;
        }
        return raw;
    }
  }

  String? _validateField(DebugFieldView field, String? value) {
    if (!field.editable) {
      return null;
    }
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (field.optional || field.type == DebugFieldType.boolean) {
        return null;
      }
      return '不能为空';
    }
    try {
      _parseFieldValue(field, trimmed);
      return null;
    } catch (err) {
      return '格式错误: $err';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isNew
        ? '新增 ${widget.collection.name}'
        : '编辑 ${widget.collection.name}';
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final binding in _bindings)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _FieldEditor(
                      binding: binding,
                      validator: (value) =>
                          _validateField(binding.field, value),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }
}

class _FieldBinding {
  _FieldBinding.textField({
    required this.field,
    required TextEditingController controller,
  }) : textController = controller,
       boolController = null;

  _FieldBinding.boolField({
    required this.field,
    required ValueNotifier<bool> controller,
  }) : boolController = controller,
       textController = null;

  final DebugFieldView field;
  final TextEditingController? textController;
  final ValueNotifier<bool>? boolController;

  void dispose() {
    textController?.dispose();
    boolController?.dispose();
  }
}

class _FieldEditor extends StatelessWidget {
  const _FieldEditor({required this.binding, required this.validator});

  final _FieldBinding binding;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final field = binding.field;
    if (field.type == DebugFieldType.boolean) {
      return ValueListenableBuilder<bool>(
        valueListenable: binding.boolController ?? ValueNotifier(false),
        builder: (context, value, _) {
          return SwitchListTile(
            value: value,
            onChanged: field.editable
                ? (val) => binding.boolController?.value = val
                : null,
            title: Text(field.label),
          );
        },
      );
    }

    final controller = binding.textController;
    final isMultiline =
        field.type == DebugFieldType.text || field.type == DebugFieldType.bytes;
    TextInputType? keyboardType;
    if (field.type == DebugFieldType.int) {
      keyboardType = TextInputType.number;
    } else if (field.type == DebugFieldType.double) {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    } else if (field.type == DebugFieldType.dateTime) {
      keyboardType = TextInputType.datetime;
    }

    return TextFormField(
      controller: controller,
      readOnly: !field.editable,
      maxLines: isMultiline ? null : 1,
      minLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        helperText: field.optional ? '可留空' : null,
      ),
      keyboardType: keyboardType,
      validator: field.editable ? validator : null,
    );
  }
}
