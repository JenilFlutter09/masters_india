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
import 'line_output_controller.dart';

class LineOutputScreen extends GetView<LineOutputController> {
  const LineOutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Line Output Weighing')),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Creating mother coil output...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Furnace Output',
              subtitle:
                  'Tablet mode keeps the live issue weight visible on the left while production, alloy, and timestamp controls stay grouped on the right.',
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
                title: 'Output Details',
                subtitle:
                    'Choose the production mode, map the output to its line and alloy, then stamp the production times.',
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.outputType.value,
                        decoration: const InputDecoration(
                          labelText: 'Production Type',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Rod', child: Text('Rod')),
                          DropdownMenuItem(
                            value: 'Sheet',
                            child: Text('Sheet'),
                          ),
                        ],
                        onChanged: controller.setOutputType,
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
                    AppDropdownField(
                      label: 'Metal Alloy',
                      options: controller.metalAlloys,
                      value: controller.selectedMetalAlloyId.value,
                      onChanged: controller.selectedMetalAlloyId.call,
                      validator: (value) =>
                          controller.validateSelection(value, 'Metal alloy'),
                    ),
                    AppTextField(
                      label: 'CCTV Reference',
                      controller: controller.cctvRefController,
                    ),
                    AppTextField(
                      label: 'Produced At',
                      controller: controller.producedAtController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Produced at'),
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
                        : 'Create Mother Coil Output',
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
