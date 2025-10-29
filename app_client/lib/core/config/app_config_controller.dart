/// Riverpod 配置状态管理器，提供运行时切换服务节点和日志等级的能力。
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:im_client/core/config/app_config.dart';

/// 将配置模型暴露为 `StateNotifier`，方便 UI 响应式更新。
class AppConfigNotifier extends StateNotifier<AppConfigData> {
  AppConfigNotifier(AppConfigData initialState) : super(initialState);

  /// 切换当前激活的服务节点，重复选择时直接跳过。
  void setActiveServer(String serverId) {
    if (serverId == state.activeServerId) {
      return;
    }
    state = state.copyWith(activeServerId: serverId);
  }

  /// 更新日志等级，避免触发无效的状态刷新。
  void setLogLevel(LogLevelSetting level) {
    if (level == state.logLevel) {
      return;
    }
    state = state.copyWith(logLevel: level);
  }

  /// 用完整的新配置替换当前状态（用于加载配置文件）。
  void replace(AppConfigData data) {
    state = data;
  }
}
