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
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'scrap_weighing_controller.dart';

class ScrapWeighingScreen extends GetView<ScrapWeighingController> {
  const ScrapWeighingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Scrap Weighing'),
      body: Obx(
        () => DefaultTabController(
          length: 2,
          initialIndex: controller.selectedMovementTab.value,
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
                title: 'Scrap Weighing',
                subtitle: controller.screenSubtitle,
                onRefresh: controller.refreshScreen,
                topWidgets: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TabBar(
                      onTap: controller.onMovementTabChanged,
                      tabs: const [
                        Tab(text: 'Scrap Yard to Line'),
                        Tab(text: 'Line to Scrap Yard'),
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
                  title: 'Scrap Weight Station',
                  subtitle:
                      'Capture gross and tare here. The scrap movement API receives the calculated net weight.',
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
                  title: controller.movementTitle,
                  subtitle: controller.movementSubtitle,
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
                          onChanged:
                              controller.selectedRawMaterialChoiceId.call,
                          validator: (value) => controller.validateSelection(
                            value,
                            'Raw material',
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
                          : controller.submitLabel,
                    ),
                  ),
                ),
                result: Column(
                  children: [
                    if (controller.submissionResult.value != null)
                      SubmissionResultCard(
                        data: controller.submissionResult.value!,
                      ),
                    if (controller.savedEntries.isNotEmpty) ...[
                      if (controller.submissionResult.value != null)
                        const SizedBox(height: 18),
                      SectionCard(
                        title: 'Scrap Entry Logs',
                        subtitle:
                            'Each successful save adds a running batch-style entry log for this session.',
                        child: Column(
                          children: controller.savedEntries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Dismissible(
                                    key: ValueKey(
                                      '${entry.referenceId}-${entry.recordedAt}',
                                    ),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) =>
                                        controller.removeSavedEntry(entry),
                                    child: _ScrapEntryCard(entry: entry),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrapEntryCard extends StatelessWidget {
  const _ScrapEntryCard({required this.entry});

  final ScrapMovementEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.directionLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Ref ${entry.referenceId}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _EntryStat(label: 'Staff', value: entry.staffName),
              _EntryStat(label: 'Line', value: entry.productionLineName),
              _EntryStat(label: 'Material', value: entry.rawMaterialLabel),
              _EntryStat(
                label: 'Gross',
                value: '${entry.grossWeight.toStringAsFixed(2)} kg',
              ),
              _EntryStat(
                label: 'Tare',
                value: '${entry.tareWeight.toStringAsFixed(2)} kg',
              ),
              _EntryStat(
                label: 'Net',
                value: '${entry.netWeight.toStringAsFixed(2)} kg',
              ),
              _EntryStat(label: 'Time', value: entry.recordedAt),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryStat extends StatelessWidget {
  const _EntryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
