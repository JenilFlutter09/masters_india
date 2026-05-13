import 'package:get/get.dart';

import '../../features/auth/data/auth_repository.dart';
import '../models/auth_session.dart';
import '../models/app_exception.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  AuthService({
    required StorageService storageService,
    required AuthRepository authRepository,
  }) : _storageService = storageService,
       _authRepository = authRepository;

  final StorageService _storageService;
  final AuthRepository _authRepository;

  final isLoggedIn = false.obs;
  final userEmail = RxnString();
  final userName = RxnString();
  final userId = RxnInt();
  final session = Rxn<AuthSession>();

  Future<void> restoreSession() async {
    final token = _storageService.token;
    final email = _storageService.userEmail;
    final name = _storageService.userName;
    final id = _storageService.userId;
    isLoggedIn.value = token != null && token.isNotEmpty;
    userEmail.value = email;
    userName.value = name;
    userId.value = id;
    if (isLoggedIn.value && email != null) {
      session.value = AuthSession(
        token: token ?? '',
        userId: id ?? 0,
        name: name ?? '',
        email: email,
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _authRepository.login(
      email: email,
      password: password,
    );
    final parsedSession = AuthSession.fromLoginResponse(response);
    if (parsedSession.token.isEmpty) {
      throw const AppException(
        'Login succeeded but no auth token was returned.',
      );
    }

    await _storageService.saveToken(parsedSession.token);
    await _storageService.saveUserEmail(parsedSession.email);
    await _storageService.saveUserName(parsedSession.name);
    await _storageService.saveUserId(parsedSession.userId);
    isLoggedIn.value = true;
    userEmail.value = parsedSession.email;
    userName.value = parsedSession.name;
    userId.value = parsedSession.userId;
    session.value = parsedSession;
  }

  Future<void> logout() async {
    try {
      if ((_storageService.token ?? '').isNotEmpty) {
        await _authRepository.logout();
      }
    } catch (_) {}
    await _storageService.clearSession();
    isLoggedIn.value = false;
    userEmail.value = null;
    userName.value = null;
    userId.value = null;
    session.value = null;
  }

  Future<void> refreshCurrentUser() async {
    final response = await _authRepository.me();
    final data =
        (response['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    userEmail.value = user['email']?.toString();
    userName.value = user['name']?.toString();
    userId.value = (user['id'] as num?)?.toInt();
    await _storageService.saveUserEmail(userEmail.value);
    await _storageService.saveUserName(userName.value);
    await _storageService.saveUserId(userId.value);
  }
}
