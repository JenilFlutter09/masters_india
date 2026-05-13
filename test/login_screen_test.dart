import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:mastersindia/features/auth/presentation/login_controller.dart';
import 'package:mastersindia/features/auth/presentation/login_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('login screen shows credentials fields and action button', (
    tester,
  ) async {
    await bootstrapTestBindings();
    final context = await createTestContext();
    Get.put(LoginController(authService: context.authService));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Shop Floor Login'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
