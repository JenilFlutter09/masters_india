import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/app_exception.dart';
import '../../../core/services/auth_service.dart';

class LoginController extends GetxController {
  LoginController({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'admin@example.com');
  final passwordController = TextEditingController(text: 'admin123');
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  Future<void> login() async {
    errorMessage.value = null;
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSubmitting.value = true;
    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } on AppException catch (error) {
      errorMessage.value = error.message;
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
