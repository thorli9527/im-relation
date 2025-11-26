import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:app_desktop/src/rust/frb_generated.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/screens/home/home_page.dart';
import 'package:app_desktop/screens/login_page.dart';
import 'package:app_desktop/screens/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const ProviderScope(child: MyApp()));
}

/// 全局路由配置：登录、注册、首页。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final overrideLocale = ref.watch(localeOverrideProvider);
    final savedLocale = ref.watch(savedLocaleProvider).maybeWhen(
          data: (l) => l,
          orElse: () => null,
        );

    return MaterialApp.router(
      title: 'IM Client',
      routerConfig: router,
      locale: overrideLocale ?? savedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
