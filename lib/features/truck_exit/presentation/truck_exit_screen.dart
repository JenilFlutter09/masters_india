import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_string_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/weighbridge_weight_panel.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_info_field.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'truck_exit_controller.dart';

class TruckExitScreen extends GetView<TruckExitController> {
  const TruckExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Truck Exit'),
      body: Obx(
        () => DefaultTabController(
          length: 2,
          initialIndex: controller.selectedExitTab.value,
          child: LoadingOverlay(
            visible:
                controller.isLoadingMasters.value ||
                controller.isSubmitting.value,
            message: controller.isSubmitting.value
                ? controller.submittingMessage
                : 'Loading options...',
            child: Form(
              key: controller.formKey,
              child: WorkflowScreenShell(
                title: 'Outbound Weighbridge',
                subtitle:
                    'Use one common weighbridge screen for finished-goods dispatch and empty truck release, while keeping gross and tare capture consistent on the left.',
                onRefresh: controller.refreshScreen,
                topWidgets: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TabBar(
                      onTap: controller.onExitTabChanged,
                      tabs: const [
                        Tab(text: 'Dispatch (Finished Goods)'),
                        Tab(text: 'Empty Exit'),
                      ],
                    ),
                  ),
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
                  subtitle: controller.weightStationSubtitle,
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
                  title: controller.exitTitle,
                  subtitle: controller.exitSubtitle,
                  child: WorkflowFieldRows(
                    rows: [
                      [
                        AppStringDropdownField(
                          label: 'Receipt Number',
                          options: controller.receiptNumbers,
                          value: controller.selectedReceiptNumber.value,
                          hintText: 'Select receipt number',
                          onChanged: controller.onReceiptChanged,
                          validator: controller.validateReceiptSelection,
                        ),
                        AppTextField(
                          label: 'Invoice Number',
                          controller: controller.invoiceNoController,
                          readOnly: true,
                        ),
                      ],
                      [
                        AppTextField(
                          label: 'Truck Number',
                          controller: controller.truckNumberController,
                          readOnly: true,
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
                      if (controller.isDispatchTab) ...[
                        [
                          AppDropdownField(
                            label: 'Customer',
                            options: controller.customers,
                            value: controller.selectedCustomerId.value,
                            onChanged: controller.selectedCustomerId.call,
                            validator: (value) =>
                                controller.validateSelection(value, 'Customer'),
                          ),
                          AppStringDropdownField(
                            label: 'Finished Goods Type',
                            options: TruckExitController.finishedGoodsTypes,
                            value: controller.selectedFinishedGoodsType.value,
                            onChanged: controller.onFinishedGoodsTypeChanged,
                            validator: (value) =>
                                controller.validateStringSelection(
                                  value,
                                  'Finished goods type',
                                ),
                          ),
                        ],
                        if (controller.selectedFinishedGoodsType.value ==
                            'raw_material')
                          [
                            AppDropdownField(
                              label: 'Raw Material',
                              options: controller.rawMaterials,
                              value:
                                  controller.selectedRawMaterialChoiceId.value,
                              onChanged:
                                  controller.selectedRawMaterialChoiceId.call,
                              validator: (value) => controller
                                  .validateSelection(value, 'Raw material'),
                            ),
                            const WorkflowInfoField(
                              label: 'Dispatch Detail',
                              value:
                                  'Choose the exact raw material variant being sent out.',
                            ),
                          ],
                        if (controller.selectedFinishedGoodsType.value ==
                            'dross')
                          [
                            AppStringDropdownField(
                              label: 'Dross Type',
                              options: controller.drossTypes,
                              value: controller.selectedDrossType.value,
                              onChanged: controller.selectedDrossType.call,
                              validator: (value) => controller
                                  .validateStringSelection(value, 'Dross type'),
                            ),
                            const WorkflowInfoField(
                              label: 'Dispatch Detail',
                              value:
                                  'Select the exact dross type for this finished-goods load.',
                            ),
                          ],
                        if (controller.selectedFinishedGoodsType.value ==
                            'mother_coil')
                          [
                            AppDropdownField(
                              label: 'Mother Coil Product',
                              options: controller.motherCoilProducts,
                              value:
                                  controller.selectedMotherCoilProductId.value,
                              onChanged:
                                  controller.selectedMotherCoilProductId.call,
                              validator: (value) =>
                                  controller.validateSelection(
                                    value,
                                    'Mother coil product',
                                  ),
                            ),
                            const WorkflowInfoField(
                              label: 'Dispatch Detail',
                              value:
                                  'Map this dispatch to the mother coil product being loaded.',
                            ),
                          ],
                        if (controller.selectedFinishedGoodsType.value ==
                            'baby_coil')
                          [
                            AppDropdownField(
                              label: 'Baby Coil Product',
                              options: controller.babyCoilProducts,
                              value: controller.selectedBabyCoilProductId.value,
                              onChanged:
                                  controller.selectedBabyCoilProductId.call,
                              validator: (value) =>
                                  controller.validateSelection(
                                    value,
                                    'Baby coil product',
                                  ),
                            ),
                            const WorkflowInfoField(
                              label: 'Dispatch Detail',
                              value:
                                  'Map this dispatch to the baby coil product being loaded.',
                            ),
                          ],
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
                          : controller.submitLabel,
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
      ),
    );
  }
}
