import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_info_field.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'line_output_controller.dart';

class LineOutputScreen extends GetView<LineOutputController> {
  const LineOutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Line Output Weighing'),
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
                  'Capture mother coil inward from production line output by selecting the exact line, alloy, product, and gross/tare weights required by the furnace-output API.',
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
              leftPanel: WeighbridgeWeightPanel(
                title: 'Output Weight Station',
                subtitle:
                    'Capture gross and tare for the furnace output here. Net weight is calculated automatically for the mother coil entry.',
                scaleStatus: controller.scaleStatus,
                isScaleConnected: controller.scaleService.isScaleConnected,
                printerStatus: controller.printerStatus,
                liveReading: controller.liveReading.value,
                grossWeightController: controller.grossWeightController,
                tareWeightController: controller.tareWeightController,
                onCaptureGross: controller.captureGrossWeight,
                onCaptureTare: controller.captureTareWeight,
                grossValidator: (value) =>
                    controller.validateRequiredWeightValue(
                      value,
                      'Gross weight',
                    ),
                tareValidator: (value) =>
                    controller.validateOptionalWeightValue(
                      value,
                      'Tare weight',
                    ),
              ),
              rightPanel: SectionCard(
                title: 'Output Details',
                subtitle:
                    'Only the fields required by furnace output are shown here so the saved payload maps directly to the API contract.',
                child: WorkflowFieldRows(
                  rows: [
                    [
                      AppDropdownField(
                        label: 'Production Line',
                        options: controller.productionLines,
                        value: controller.selectedProductionLineId.value,
                        onChanged: controller.onProductionLineChanged,
                        validator: (value) => controller.validateSelection(
                          value,
                          'Production line',
                        ),
                      ),
                      AppDropdownField(
                        label: 'Mother Coil Product',
                        options: controller.motherCoilProducts,
                        value: controller.selectedMotherCoilProductId.value,
                        onChanged: controller.selectedMotherCoilProductId.call,
                        validator: (value) => controller.validateSelection(
                          value,
                          'Mother coil product',
                        ),
                      ),
                    ],
                    [
                      AppDropdownField(
                        label: 'Metal Alloy',
                        options: controller.metalAlloys,
                        value: controller.selectedMetalAlloyId.value,
                        onChanged: controller.selectedMetalAlloyId.call,
                        validator: (value) =>
                            controller.validateSelection(value, 'Metal alloy'),
                      ),
                      WorkflowInfoField(
                        label: 'Line Product Hint',
                        value:
                            controller.lineAssignedProductName ??
                            'Select a production line to view the mapped product.',
                        muted: controller.lineAssignedProductName == null,
                      ),
                    ],
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
                  : Column(
                      children: [
                        SubmissionResultCard(
                          data: controller.submissionResult.value!,
                        ),
                        if (controller.canUndoLatestOutput) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.undoLatestOutput,
                              icon: const Icon(Icons.undo_rounded),
                              label: const Text(
                                'Undo Latest Mother Coil Output',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
