import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/device_connection_bottom_sheet.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const CustomAppBar(title: 'Settings'),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (controller.feedback.value != null)
              StatusBanner(message: controller.feedback.value!, isError: false),
            SectionCard(
              title: 'Backend Configuration',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Base URL',
                    controller: controller.baseUrlController,
                  ),
                  AppTextField(
                    label: 'Login Path',
                    controller: controller.loginPathController,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveConfig,
                      child: Text(
                        controller.isSaving.value
                            ? 'Saving...'
                            : 'Save Configuration',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: 'Scale Device',
              subtitle:
                  'Pair the floor scale through Android Bluetooth first, then connect it here.',
              child: _DeviceSection(
                status: controller.scaleEndpoint.status.value,
                selectedName: controller.scaleEndpoint.selectedName,
                actionLabel: controller.scaleService.isScaleConnected
                    ? 'Disconnect Scale'
                    : 'Open Scale Sheet',
                onPressed: () async {
                  if (controller.scaleService.isScaleConnected) {
                    await controller.disconnectScale();
                    return;
                  }
                  await showScaleConnectionSheet(context);
                },
                isConnected: controller.scaleService.isScaleConnected,
              ),
            ),
            SectionCard(
              title: 'Printer Device',
              subtitle:
                  'Connect the SNBC label printer used for dross, mother coil, and baby-product labels.',
              child: _DeviceSection(
                status: controller.printerService.deviceStatus,
                selectedName: controller.printerService.selectedPrinterName,
                actionLabel: controller.printerService.isPrinterConnected
                    ? 'Disconnect Printer'
                    : 'Open Printer Sheet',
                onPressed: () async {
                  if (controller.printerService.isPrinterConnected) {
                    await controller.disconnectPrinter();
                    return;
                  }
                  await showPrinterConnectionSheet(context);
                },
                isConnected: controller.printerService.isPrinterConnected,
              ),
            ),
            SectionCard(
              title: 'Diagnostics',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.refreshDevices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Devices'),
                  ),
                  ElevatedButton.icon(
                    onPressed: controller.testScaleRead,
                    icon: const Icon(Icons.sensors_outlined),
                    label: const Text('Test Scale Read'),
                  ),
                  ElevatedButton.icon(
                    onPressed: controller.testPrint,
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Test Print'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceSection extends StatelessWidget {
  const _DeviceSection({
    required this.status,
    required this.selectedName,
    required this.actionLabel,
    required this.onPressed,
    this.isConnected = false,
  });

  final String status;
  final String? selectedName;
  final String actionLabel;
  final Future<void> Function() onPressed;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status: $status'),
        if (selectedName != null) ...[
          const SizedBox(height: 6),
          Text('Selected: $selectedName'),
        ],
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isConnected
                ? const Color(0xFFF1F8F3)
                : const Color(0xFFF6F8FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isConnected
                ? 'The active device is connected and ready to use.'
                : 'Use the shared bottom sheet to choose the paired device you want to use.',
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () async {
              await onPressed();
            },
            icon: Icon(
              isConnected ? Icons.link_off_rounded : Icons.bluetooth_rounded,
            ),
            label: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}
