import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/core/config/app_config.dart';
import 'package:im_client/core/config/app_config_controller.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/core/storage/local_store.dart';

import 'features/auth/startup_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configData = await AppConfigLoader.load();
  final localStore = await LocalStore.open();
  runApp(
    ProviderScope(
      overrides: [
        appConfigNotifierProvider.overrideWith(
          (ref) => AppConfigNotifier(configData),
        ),
        localStoreProvider.overrideWithValue(localStore),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IM Client',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StartupGate(),
    );
  }
}
