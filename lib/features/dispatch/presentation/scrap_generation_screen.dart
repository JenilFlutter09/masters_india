import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'scrap_generation_controller.dart';

class ScrapGenerationScreen extends GetView<ScrapGenerationController> {
  const ScrapGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Scrap Generation'),
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
              leftPanel: WeighbridgeWeightPanel(
                title: 'Return Weight Station',
                subtitle:
                    'Capture gross and tare for the return scrap here. Net weight is posted back to the yard movement.',
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
                title: 'Return Details',
                subtitle:
                    'Send scrap back to the yard by choosing the line, operator, and raw material variant for this return movement.',
                child: WorkflowFieldRows(
                  rows: [
                    [
                      AppDropdownField(
                        label: 'Staff',
                        options: controller.staffMembers,
                        value: controller.selectedStaffId.value,
                        onChanged: controller.selectedStaffId.call,
                        validator: (value) =>
                            controller.validateSelection(value, 'Staff'),
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
                    ],
                    [
                      AppDropdownField(
                        label: 'Raw Material',
                        options: controller.rawMaterials,
                        value: controller.selectedRawMaterialChoiceId.value,
                        onChanged: controller.selectedRawMaterialChoiceId.call,
                        validator: (value) =>
                            controller.validateSelection(value, 'Raw material'),
                      ),
                      AppTextField(
                        label: 'Recorded At',
                        controller: controller.recordedAtController,
                        readOnly: true,
                        validator: (value) =>
                            controller.validateText(value, 'Recorded at'),
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
