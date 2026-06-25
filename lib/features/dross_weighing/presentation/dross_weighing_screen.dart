import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_string_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_info_field.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'dross_weighing_controller.dart';

class DrossWeighingScreen extends GetView<DrossWeighingController> {
  const DrossWeighingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Dross Weighing'),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Saving dross inward...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Dross Inward',
              subtitle:
                  'Monitor live weight on the left and map the inward record to the correct line and dross type on the right.',
              onRefresh: controller.refreshScreen,
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
                title: 'Dross Weight Station',
                subtitle:
                    'Capture gross and tare here. The dross inward API receives the net weight after deduction.',
                scaleStatus: controller.scaleStatus,
                isScaleConnected: controller.scaleService.isScaleConnected,
                printerStatus: controller.printerStatus,
                liveReading: controller.liveReading.value,
                grossWeightController: controller.grossWeightController,
                tareWeightController: controller.tareWeightController,
                onCaptureGross: controller.captureGrossWeight,
                onCaptureTare: controller.captureTareWeight,
                grossValidator: (value) => controller
                    .validateRequiredWeightValue(value, 'Gross weight'),
                tareValidator: (value) => controller
                    .validateOptionalWeightValue(value, 'Tare weight'),
              ),
              rightPanel: SectionCard(
                title: 'Classification Details',
                subtitle:
                    'Assign the dross to its production line and material type before printing the label.',
                child: WorkflowFieldRows(
                  rows: [
                    [
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
                      AppStringDropdownField(
                        label: 'Dross Type',
                        options: controller.drossTypes,
                        value: controller.selectedDrossType.value,
                        onChanged: controller.selectedDrossType.call,
                        validator: (value) => controller.validateTypeSelection(
                          value,
                          'Dross type',
                        ),
                      ),
                    ],
                    [
                      AppTextField(
                        label: 'Recorded At',
                        controller: controller.recordedAtController,
                        readOnly: true,
                        validator: (value) =>
                            controller.validateText(value, 'Recorded at'),
                      ),
                      const WorkflowInfoField(
                        label: 'Label Flow',
                        value:
                            'Save the inward record to print the dross label.',
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
                        : 'Save and Print Label',
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
