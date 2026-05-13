import 'package:flutter_test/flutter_test.dart';

import 'package:mastersindia/core/services/auth_service.dart';

import 'helpers/test_services.dart';

void main() {
  test('auth service parses nested login response', () async {
    await bootstrapTestBindings();
    final context = await createTestContext();

    await context.authService.login(
      email: 'admin@example.com',
      password: 'admin123',
    );

    expect(context.authService.isLoggedIn.value, isTrue);
    expect(context.authService.userEmail.value, 'admin@example.com');
    expect(context.authService.userName.value, 'Admin User');
    expect(context.authService.userId.value, 1);
  });

  test('auth service restores and clears session', () async {
    await bootstrapTestBindings();
    final context = await createTestContext();

    await context.storageService.saveToken('demo-token');
    await context.storageService.saveUserEmail('admin@example.com');
    await context.storageService.saveUserName('Admin User');
    await context.storageService.saveUserId(1);

    final authService = AuthService(
      storageService: context.storageService,
      authRepository: context.authRepository,
    );

    await authService.restoreSession();
    expect(authService.isLoggedIn.value, isTrue);
    expect(authService.userEmail.value, 'admin@example.com');
    expect(authService.userName.value, 'Admin User');
    expect(authService.userId.value, 1);

    await authService.logout();
    expect(authService.isLoggedIn.value, isFalse);
    expect(authService.userEmail.value, isNull);
  });
}
