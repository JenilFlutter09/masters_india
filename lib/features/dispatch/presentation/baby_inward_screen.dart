import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'baby_inward_controller.dart';

class BabyInwardScreen extends GetView<BabyInwardController> {
  const BabyInwardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Baby Inward'),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Creating baby inward...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Baby Inward',
              subtitle:
                  'Run the weight station on the left and capture the mother coil linkage and label timing on the right.',
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
                title: 'Baby Inward Weight Station',
                subtitle:
                    'Capture gross and tare for the baby inward item here. Net weight is submitted after deduction.',
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
                title: 'Item Details',
                subtitle:
                    'Confirm which mother coil is being converted, choose the baby product, and capture any product parameters before saving.',
                child: WorkflowFieldRows(
                  rows: [
                    [
                      AppDropdownField(
                        label: 'Available Mother Coil',
                        options: controller.availableMotherCoils,
                        value: controller.selectedMotherCoilId.value,
                        onChanged: controller.onMotherCoilChanged,
                        validator: (value) => controller.validateSelection(
                          value,
                          'Available mother coil',
                        ),
                      ),
                      AppTextField(
                        label: 'Item Type',
                        controller: controller.itemTypeController,
                        validator: (value) =>
                            controller.validateText(value, 'Item type'),
                      ),
                    ],
                    [
                      AppTextField(
                        label: 'Mother Coil ID',
                        controller: controller.motherCoilIdController,
                        readOnly: true,
                        validator: (value) => controller.validateIntegerValue(
                          value,
                          'Mother coil ID',
                        ),
                      ),
                    ],
                    [
                      AppDropdownField(
                        label: 'Baby Product',
                        options: controller.babyProducts,
                        value: controller.selectedBabyProductId.value,
                        onChanged: controller.onBabyProductChanged,
                        validator: (value) =>
                            controller.validateSelection(value, 'Baby product'),
                      ),
                    ],
                    if (controller.parameterKeys.isNotEmpty)
                      [_BabyProductParameterFields(controller: controller)],
                    [
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

class _BabyProductParameterFields extends StatelessWidget {
  const _BabyProductParameterFields({required this.controller});

  final BabyInwardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <List<Widget>>[];
    for (var index = 0; index < controller.parameterKeys.length; index += 2) {
      final firstKey = controller.parameterKeys[index];
      rows.add([
        AppTextField(
          label: firstKey,
          controller: controller.parameterControllers[firstKey]!,
          validator: (value) =>
              controller.validateParameterValue(value, firstKey),
        ),
        if (index + 1 < controller.parameterKeys.length)
          AppTextField(
            label: controller.parameterKeys[index + 1],
            controller: controller
                .parameterControllers[controller.parameterKeys[index + 1]]!,
            validator: (value) => controller.validateParameterValue(
              value,
              controller.parameterKeys[index + 1],
            ),
          )
        else
          const SizedBox.shrink(),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Baby Product Parameters',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          WorkflowFieldRows(rows: rows),
        ],
      ),
    );
  }
}
