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
import 'baby_inward_controller.dart';

class BabyInwardScreen extends GetView<BabyInwardController> {
  const BabyInwardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Baby Inward')),
      body: Obx(
        () => LoadingOverlay(
          visible: controller.isSubmitting.value,
          message: 'Creating baby inward...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Baby Inward',
              subtitle:
                  'Run the weight station on the left and capture the mother coil linkage and label timing on the right.',
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
                title: 'Item Details',
                subtitle:
                    'Confirm which mother coil is being converted and when the item and label were produced.',
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
                      label: 'Item Type',
                      controller: controller.itemTypeController,
                      validator: (value) =>
                          controller.validateText(value, 'Item type'),
                    ),
                    AppTextField(
                      label: 'Created On',
                      controller: controller.createdOnController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Created on'),
                    ),
                    AppTextField(
                      label: 'Label Printed At',
                      controller: controller.labelPrintedAtController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Label printed at'),
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
                        : 'Create Baby Inward',
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
