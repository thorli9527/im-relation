import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';

class IMDesktopApp extends ConsumerWidget {
  const IMDesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'IM Relation Desktop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(context),
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  late final ProviderSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (next.status == AuthStatus.authenticated) {
          final session = next.session!;
          ref
              .read(chatControllerProvider.notifier)
              .bootstrap(session: session);
        }
        if (previous?.status == AuthStatus.authenticated &&
            next.status == AuthStatus.unauthenticated) {
          ref.read(chatControllerProvider.notifier).reset();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    switch (authState.status) {
      case AuthStatus.initializing:
      case AuthStatus.authenticating:
        return const _SplashScreen();
      case AuthStatus.failure:
      case AuthStatus.unauthenticated:
        return LoginPage(errorMessage: authState.errorMessage);
      case AuthStatus.authenticated:
        return const HomePage();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceVariant,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(strokeWidth: 5),
              ),
              SizedBox(height: 24),
              Text(
                '正在连接 IM Relation 服务…',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
