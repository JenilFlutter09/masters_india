import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/barcode_scanner_dialog.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/submission_result_card.dart';
import '../../../shared/widgets/workflow_field_rows.dart';
import '../../../shared/widgets/workflow_screen_shell.dart';
import 'dispatch_controller.dart';

class DispatchScreen extends GetView<DispatchController> {
  const DispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Dispatch'),
      body: Obx(
        () => DefaultTabController(
          length: 2,
          initialIndex: controller.selectedDispatchTab.value,
          child: LoadingOverlay(
            visible:
                controller.isLoadingMasters.value ||
                controller.isSubmitting.value,
            message: controller.isSubmitting.value
                ? 'Saving dispatch...'
                : 'Loading options...',
            child: Form(
              key: controller.formKey,
              child: WorkflowScreenShell(
                title: 'Dispatch',
                subtitle:
                    'Use one shared scanner-driven dispatch screen for mother coils and baby products, without the weighbridge panel.',
                onRefresh: controller.refreshScreen,
                topWidgets: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TabBar(
                      onTap: controller.onDispatchTabChanged,
                      tabs: const [
                        Tab(text: 'Mother Coil'),
                        Tab(text: 'Baby Product'),
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
                /* leftPanel: SectionCard(
                  title: controller.scannerPanelTitle,
                  subtitle: controller.scannerPanelSubtitle,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: WorkflowInfoField(
                              label: 'Dispatch Mode',
                              value: controller.dispatchModeLabel,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await showBarcodeScannerDialog(
                                  context,
                                );
                                if (result == null || result.trim().isEmpty) {
                                  return;
                                }
                                controller.applyScannedCode(result);
                              },
                              icon: const Icon(Icons.document_scanner_outlined),
                              label: const Text('Open Scanner'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: WorkflowInfoField(
                              label: controller.isMotherCoilTab
                                  ? 'Parsed Identifier'
                                  : 'Scanned Barcode',
                              value: controller.identifierSummaryValue,
                              muted: controller.activeCodeController.text
                                  .trim()
                                  .isEmpty,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: WorkflowInfoField(
                              label: 'Scanned Value',
                              value: controller.scanSummaryValue,
                              muted: controller.activeCodeController.text
                                  .trim()
                                  .isEmpty,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: WorkflowInfoField(
                              label: 'Customer',
                              value:
                                  controller.selectedCustomer?.name ??
                                  'Select the dispatch customer',
                              muted: controller.selectedCustomer == null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: WorkflowInfoField(
                              label: 'Dispatch Check',
                              value: controller.isMotherCoilTab
                                  ? 'The scanned mother coil ID will be resolved and dispatched for the selected customer.'
                                  : 'The scanned baby product barcode will be dispatched for the selected customer.',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),*/
                rightPanel: SectionCard(
                  title: controller.pageTitle,
                  subtitle: controller.detailsSubtitle,
                  child: WorkflowFieldRows(
                    rows: [
                      [
                        AppTextField(
                          label: controller.primaryFieldLabel,
                          controller: controller.activeCodeController,
                          focusNode: controller.activeFocusNode,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          hintText: controller.primaryFieldHint,
                          suffixIcon: const Icon(Icons.qr_code_scanner_rounded),
                          validator: (value) => controller.isMotherCoilTab
                              ? controller.validateCoilBarcodeOrId(
                                  value,
                                  controller.primaryFieldLabel,
                                )
                              : controller.validateText(
                                  value,
                                  controller.primaryFieldLabel,
                                ),
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
                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await showBarcodeScannerDialog(
                              context,
                            );
                            if (result == null || result.trim().isEmpty) {
                              return;
                            }
                            controller.applyScannedCode(result);
                          },
                          icon: const Icon(Icons.document_scanner_outlined),
                          label: Text(
                            controller.isMotherCoilTab
                                ? 'Scan Mother Coil'
                                : 'Scan Baby Product',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
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
                          : controller.isMotherCoilTab
                          ? 'Dispatch Mother Coil'
                          : 'Dispatch Baby Product',
                    ),
                  ),
                ),
                result:
                    controller.submissionResult.value == null &&
                        controller.savedEntries.isEmpty
                    ? null
                    : Column(
                        children: [
                          if (controller.submissionResult.value != null)
                            SubmissionResultCard(
                              data: controller.submissionResult.value!,
                            ),
                          if (controller.savedEntries.isNotEmpty) ...[
                            if (controller.submissionResult.value != null)
                              const SizedBox(height: 18),
                            SectionCard(
                              title: 'Dispatch Entry Logs',
                              subtitle:
                                  'Each successful dispatch is added to this running session list for quick verification.',
                              child: Column(
                                children: controller.savedEntries
                                    .map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Dismissible(
                                          key: ValueKey(
                                            '${entry.referenceId}-${entry.dispatchedAt}',
                                          ),
                                          direction:
                                              DismissDirection.endToStart,
                                          background: Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade600,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onDismissed: (_) => controller
                                              .removeSavedEntry(entry),
                                          child: _DispatchEntryCard(
                                            entry: entry,
                                          ),
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

class _DispatchEntryCard extends StatelessWidget {
  const _DispatchEntryCard({required this.entry});

  final DispatchEntry entry;

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
                  entry.dispatchLabel,
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
              _DispatchEntryStat(label: 'Customer', value: entry.customerName),
              _DispatchEntryStat(
                label: 'Scanned Value',
                value: entry.scannedValue,
              ),
              _DispatchEntryStat(
                label: 'Identifier',
                value: entry.resolvedIdentifier,
              ),
              _DispatchEntryStat(label: 'Time', value: entry.dispatchedAt),
            ],
          ),
        ],
      ),
    );
  }
}

class _DispatchEntryStat extends StatelessWidget {
  const _DispatchEntryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 200,
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
