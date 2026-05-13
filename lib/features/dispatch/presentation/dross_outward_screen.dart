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
import 'dross_outward_controller.dart';

class DrossOutwardScreen extends GetView<DrossOutwardController> {
  const DrossOutwardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Dross Outward')),
      body: Obx(
        () => LoadingOverlay(
          visible: controller.isSubmitting.value,
          message: 'Saving dross outward...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Dross Outward',
              subtitle:
                  'Let the operator watch the outgoing weight on the left while the outward reference fields stay grouped on the right.',
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
                title: 'Outward Details',
                subtitle:
                    'Provide the linked inward record and outward timestamp to complete the movement.',
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Dross Inward ID',
                      controller: controller.drossInwardIdController,
                      keyboardType: TextInputType.number,
                      validator: (value) => controller.validateIntegerValue(
                        value,
                        'Dross inward ID',
                      ),
                    ),
                    AppTextField(
                      label: 'Recorded At',
                      controller: controller.recordedAtController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Recorded at'),
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
                        : 'Save Dross Outward',
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
