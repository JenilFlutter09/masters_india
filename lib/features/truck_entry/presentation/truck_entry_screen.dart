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
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'truck_entry_controller.dart';

class TruckEntryScreen extends GetView<TruckEntryController> {
  const TruckEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Truck Entry'),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Saving truck entry...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Raw Material Inward',
              subtitle:
                  'Use the left station for live scale capture and complete supplier, material, and truck details on the right.',
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
                title: 'Entry Details',
                subtitle:
                    'Capture the invoice reference, choose the raw material, then confirm the truck identity before posting inward stock.',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdownField(
                            label: 'Supplier',
                            options: controller.suppliers,
                            value: controller.selectedSupplierId.value,
                            onChanged: controller.selectedSupplierId.call,
                            validator: (value) =>
                                controller.validateSelection(value, 'Supplier'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppTextField(
                            label: 'Invoice Number',
                            controller: controller.invoiceNoController,
                            validator: (value) => controller.validateText(
                              value,
                              'Invoice number',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdownField(
                            label: 'Raw Material',
                            options: controller.rawMaterials,
                            value: controller.selectedRawMaterialChoiceId.value,
                            onChanged: controller.onRawMaterialChanged,
                            validator: (value) => controller.validateSelection(
                              value,
                              'Raw material',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppDropdownField(
                            label: 'Weighbridge',
                            options: controller.weighbridges,
                            value: controller.selectedWeighbridgeId.value,
                            onChanged: controller.selectedWeighbridgeId.call,
                            validator: (value) => controller.validateSelection(
                              value,
                              'Weighbridge',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Truck Number',
                            controller: controller.truckNumberController,
                            validator: (value) =>
                                controller.validateText(value, 'Truck number'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppTextField(
                            label: 'Weighed At',
                            controller: controller.weighedAtController,
                            readOnly: true,
                            validator: (value) =>
                                controller.validateText(value, 'Weighed at'),
                          ),
                        ),
                      ],
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
                        : 'Save Truck Entry',
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
