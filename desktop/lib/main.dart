// 文件路径: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/shared/constants.dart';

import 'router.dart';
import 'services/app_config_service.dart';
import 'services/database_service.dart';
import 'shared/window_manager_service.dart';
import 'utils/id_utils.dart'; // 添加此导入
import 'utils/log_util.dart';

void main() async {
  // 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志服务
  await LogUtil.init();
  LogUtil.info('Main', '🚀 应用启动中...');

  // 初始化窗口管理器
  await WindowManagerService.init();
  LogUtil.info('Main', '🖥️ 窗口管理器初始化完成');

// 创建 ProviderContainer 并设置到 IdUtils
  final container = ProviderContainer();
  IdUtils.setContainer(container);
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初始化数据库服务和应用配置服务
    final databaseServiceAsync = ref.watch(databaseServiceAsyncProvider);
    final appConfigServiceAsync = ref.watch(appConfigServiceProvider);

    return databaseServiceAsync.when(
      data: (databaseService) {
        LogUtil.info('MyApp', '🗄️ 数据库服务已加载');
        return appConfigServiceAsync.when(
          data: (appConfigService) {
            LogUtil.info('MyApp', '⚙️ 应用配置服务已加载');
            LogUtil.info('MyApp', '🎨 当前主题模式: ${appConfigService.themeMode}');

            return _buildApp(appConfigService);
          },
          loading: () => _buildLoading(),
          error: (error, stack) {
            LogUtil.error('MyApp', '❌ 应用配置服务加载失败', error, stack);
            return _buildError(error);
          },
        );
      },
      loading: () => _buildLoading(),
      error: (error, stack) {
        LogUtil.error('MyApp', '❌ 数据库服务加载失败', error, stack);
        return _buildError(error);
      },
    );
  }

  Widget _buildApp(AppConfigService appConfigService) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
      routerConfig: router,
    );
  }

  Widget _buildLoading() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
