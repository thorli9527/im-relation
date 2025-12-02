import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sidebar 可选择的动作。
enum SidebarAction { friends, voice, chat, settings }

/// 当前选中的侧边栏动作。
final sidebarActionProvider =
    StateProvider<SidebarAction>((_) => SidebarAction.friends);

/// 设置页的菜单项。
enum SettingsMenu { logs, logout }

/// 当前选中的设置菜单。
final settingsMenuProvider =
    StateProvider<SettingsMenu>((_) => SettingsMenu.logs);
