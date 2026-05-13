import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weight_capture_card.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'mother_coil_dispatch_controller.dart';

class MotherCoilDispatchScreen extends GetView<MotherCoilDispatchController> {
  const MotherCoilDispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Mother Coil Dispatch')),
      body: Obx(
        () => LoadingOverlay(
          visible: controller.isSubmitting.value,
          message: 'Dispatching mother coil...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Mother Coil Dispatch',
              subtitle:
                  'Keep dispatch weight visible on the left while the right side focuses on which mother coil is leaving conversion stock.',
              topWidgets: [
                if (controller.errorMessage.value != null)
                  StatusBanner(
                    message: controller.errorMessage.value!,
                    isError: true,
                  ),
                if (controller.successMessage.value != null)
                  StatusBanner(
                    message: controller.successMessage.value!,
                    isError: false,
                  ),
              ],
              leftPanel: WeightCaptureCard(controller: controller),
              rightPanel: SectionCard(
                title: 'Dispatch Details',
                subtitle:
                    'Capture the exact mother coil reference and dispatch timestamp in one compact operator panel.',
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Mother Coil ID',
                      controller: controller.motherCoilIdController,
                      keyboardType: TextInputType.number,
                      validator: (value) => controller.validateIntegerValue(
                        value,
                        'Mother coil ID',
                      ),
                    ),
                    AppTextField(
                      label: 'Dispatched At',
                      controller: controller.dispatchedAtController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Dispatched at'),
                    ),
                  ],
                ),
              ),
              primaryAction: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.submit,
                  child: Text(
                    controller.isSubmitting.value
                        ? 'Submitting...'
                        : 'Dispatch Mother Coil',
                  ),
                ),
              ),
              result: controller.submissionResult.value == null
                  ? null
                  : SubmissionResultCard(
                      data: controller.submissionResult.value!,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
