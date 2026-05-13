import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'truck_exit_controller.dart';

class TruckExitScreen extends GetView<TruckExitController> {
  const TruckExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Truck Exit')),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Saving truck exit...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Outbound Weighbridge',
              subtitle:
                  'Validate the outbound reference and customer on the right while the left station manages the live gross and tare capture.',
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
                title: 'Outbound Weight Station',
                subtitle:
                    'Use this panel to move the latest scale value into gross or tare before submitting truck exit.',
                scaleStatus: controller.scaleStatus,
                printerStatus: controller.printerStatus,
                liveReading: controller.liveReading.value,
                grossWeightController: controller.grossWeightController,
                tareWeightController: controller.tareWeightController,
                onCaptureGross: controller.captureGrossWeight,
                onCaptureTare: controller.captureTareWeight,
                grossValidator: (value) =>
                    controller.validateWeightValue(value, 'Gross weight'),
                tareValidator: (value) =>
                    controller.validateWeightValue(value, 'Tare weight'),
              ),
              rightPanel: SectionCard(
                title: 'Release Details',
                subtitle:
                    'Receipt or invoice tracing, customer mapping, and truck identification all stay together on this side.',
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Receipt Number',
                      controller: controller.receiptNoController,
                    ),
                    AppTextField(
                      label: 'Invoice Number',
                      controller: controller.invoiceNoController,
                    ),
                    AppDropdownField(
                      label: 'Customer',
                      options: controller.customers,
                      value: controller.selectedCustomerId.value,
                      onChanged: controller.selectedCustomerId.call,
                      validator: (value) =>
                          controller.validateSelection(value, 'Customer'),
                    ),
                    AppDropdownField(
                      label: 'Weighbridge',
                      options: controller.weighbridges,
                      value: controller.selectedWeighbridgeId.value,
                      onChanged: controller.selectedWeighbridgeId.call,
                      validator: (value) =>
                          controller.validateSelection(value, 'Weighbridge'),
                    ),
                    AppTextField(
                      label: 'Truck Number',
                      controller: controller.truckNumberController,
                      validator: (value) =>
                          controller.validateText(value, 'Truck number'),
                    ),
                    AppTextField(
                      label: 'Weighed At',
                      controller: controller.weighedAtController,
                      readOnly: true,
                      validator: (value) =>
                          controller.validateText(value, 'Weighed at'),
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
                        : 'Save Truck Exit',
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
