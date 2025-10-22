import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:im_client/core/config/app_config.dart';

class AppConfigNotifier extends StateNotifier<AppConfigData> {
  AppConfigNotifier(AppConfigData initialState) : super(initialState);

  void setActiveServer(String serverId) {
    if (serverId == state.activeServerId) {
      return;
    }
    state = state.copyWith(activeServerId: serverId);
  }

  void setLogLevel(LogLevelSetting level) {
    if (level == state.logLevel) {
      return;
    }
    state = state.copyWith(logLevel: level);
  }

  void replace(AppConfigData data) {
    state = data;
  }
}
