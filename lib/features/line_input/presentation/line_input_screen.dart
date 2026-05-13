import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weight_capture_card.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'line_input_controller.dart';

class LineInputScreen extends GetView<LineInputController> {
  const LineInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Line Input Weighing')),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Moving scrap to furnace...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Scrap to Furnace',
              subtitle:
                  'Keep the weight feed visible on the left while the right column ties the issue to an inward entry and production line.',
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
                if (controller.isLoadingMasters.value)
                  const LinearProgressIndicator(),
              ],
              leftPanel: WeightCaptureCard(controller: controller),
              rightPanel: SectionCard(
                title: 'Issue Details',
                subtitle:
                    'Link this movement to the right inward entry and line before posting furnace WIP.',
                child: Column(
                  children: [
                    AppTextField(
                      label: 'RM Inward Entry ID',
                      controller: controller.inwardEntryIdController,
                      keyboardType: TextInputType.number,
                      validator: (value) => controller.validateIntegerValue(
                        value,
                        'RM inward entry ID',
                      ),
                    ),
                    AppDropdownField(
                      label: 'Production Line',
                      options: controller.productionLines,
                      value: controller.selectedProductionLineId.value,
                      onChanged: controller.selectedProductionLineId.call,
                      validator: (value) => controller.validateSelection(
                        value,
                        'Production line',
                      ),
                    ),
                    AppTextField(
                      label: 'CCTV Reference',
                      controller: controller.cctvRefController,
                    ),
                    AppTextField(
                      label: 'Issued At',
                      controller: controller.issuedAtController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Issued at'),
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
                        : 'Move Scrap to Furnace',
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
