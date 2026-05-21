import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_info_field.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'baby_product_dispatch_controller.dart';

class BabyProductDispatchScreen extends GetView<BabyProductDispatchController> {
  const BabyProductDispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Baby Product Dispatch'),
      body: Obx(
        () => LoadingOverlay(
          visible:
              controller.isLoadingMasters.value ||
              controller.isSubmitting.value,
          message: controller.isSubmitting.value
              ? 'Dispatching baby product...'
              : 'Loading options...',
          child: Form(
            key: controller.formKey,
            child: WorkflowScreenShell(
              title: 'Baby Product Dispatch',
              subtitle:
                  'Keep dispatch weight live on the left while the right side handles barcode identification and customer assignment.',
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
                title: 'Dispatch Weight Station',
                subtitle:
                    'Capture gross and tare for the dispatch load here. The dispatch API receives the calculated net weight.',
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
                title: 'Dispatch Details',
                subtitle:
                    'Scan the product barcode to identify the item quickly, then select the customer and confirm dispatch.',
                child: WorkflowFieldRows(
                  rows: [
                    [
                      AppTextField(
                        label: 'Barcode',
                        controller: controller.barcodeController,
                        focusNode: controller.barcodeFocusNode,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        hintText: 'Scan barcode from the dispatched product',
                        suffixIcon: const Icon(Icons.qr_code_scanner_rounded),
                        validator: (value) =>
                            controller.validateText(value, 'Barcode'),
                      ),
                      AppDropdownField(
                        label: 'Customer',
                        options: controller.customers,
                        value: controller.selectedCustomerId.value,
                        onChanged: controller.selectedCustomerId.call,
                        validator: (value) =>
                            controller.validateSelection(value, 'Customer'),
                      ),
                    ],
                    [
                      AppTextField(
                        label: 'Dispatched At',
                        controller: controller.dispatchedAtController,
                        readOnly: true,
                        validator: (value) =>
                            controller.validateText(value, 'Dispatched at'),
                      ),
                      const WorkflowInfoField(
                        label: 'Dispatch Mode',
                        value:
                            'Scan the product barcode first, then confirm the customer.',
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
                        : 'Dispatch Baby Product',
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
