import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';
import '../data/api/api_client.dart';
import '../data/auth/auth_repository.dart';
import '../data/contacts/contact_repository.dart';
import '../data/messaging/message_repository.dart';
import '../services/socket_service.dart';


final configProvider = Provider<AppConfig>((ref) => AppConfig.defaults);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(configProvider);
  final client = ApiClient(baseUrl: config.apiBaseUrl);
  ref.onDispose(client.dispose);
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepository(ref.watch(apiClientProvider));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(ref.watch(apiClientProvider));
});

final socketServiceProvider = Provider<SocketService>((ref) {
  final config = ref.watch(configProvider);
  final service = SocketService(socketUrl: config.socketUrl);
  ref.onDispose(service.dispose);
  return service;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});
