import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'dross_outward_controller.dart';

class DrossOutwardScreen extends GetView<DrossOutwardController> {
  const DrossOutwardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Dross Outward'),
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
              leftPanel: WeighbridgeWeightPanel(
                title: 'Outward Weight Station',
                subtitle:
                    'Capture gross and tare here. Net outward weight is calculated automatically.',
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
                title: 'Outward Details',
                subtitle:
                    'Provide the linked inward record and outward timestamp to complete the movement.',
                child: WorkflowFieldRows(
                  rows: [
                    [
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
