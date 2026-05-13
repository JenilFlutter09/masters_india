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
import 'scrap_generation_controller.dart';

class ScrapGenerationScreen extends GetView<ScrapGenerationController> {
  const ScrapGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Scrap Generation')),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Saving scrap generation...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Scrap Generation',
              subtitle:
                  'Track the return scrap weight on the left and tie it back to the right furnace line and output reference on the right.',
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
                title: 'Return Details',
                subtitle:
                    'Choose the production line, reference furnace output, and note any return context before saving.',
                child: Column(
                  children: [
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
                      label: 'Furnace Output ID',
                      controller: controller.furnaceOutputIdController,
                      keyboardType: TextInputType.number,
                      validator: (value) => controller.validateIntegerValue(
                        value,
                        'Furnace output ID',
                      ),
                    ),
                    AppTextField(
                      label: 'Remarks',
                      controller: controller.remarksController,
                      maxLines: 3,
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
                        : 'Save Scrap Generation',
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
