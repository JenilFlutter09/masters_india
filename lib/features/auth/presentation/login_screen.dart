import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../core/utils/form_validators.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4F8FD), Color(0xFFDCE8F8), Color(0xFFBFD4F3)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Obx(
                    () => LoadingOverlay(
                      visible: controller.isSubmitting.value,
                      message: 'Signing in...',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shop Floor Login',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to access weighbridge, production, and dispatch workflows.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          if (controller.errorMessage.value != null)
                            StatusBanner(
                              message: controller.errorMessage.value!,
                              isError: true,
                            ),
                          AppTextField(
                            label: 'Email',
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                FormValidators.requiredField(value, 'Email'),
                          ),
                          AppTextField(
                            label: 'Password',
                            controller: controller.passwordController,
                            validator: (value) =>
                                FormValidators.requiredField(value, 'Password'),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : controller.login,
                              child: Text(
                                controller.isSubmitting.value
                                    ? 'Signing in...'
                                    : 'Login',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
