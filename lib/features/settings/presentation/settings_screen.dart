import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
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
                devices: controller.scaleEndpoint.pairedDevices,
                status: controller.scaleEndpoint.status.value,
                selectedName: controller.scaleEndpoint.selectedName,
                onConnect: controller.connectScale,
              ),
            ),
            SectionCard(
              title: 'Printer Device',
              subtitle:
                  'Connect the Bluetooth printer used for dross and mother coil labels.',
              child: _DeviceSection(
                devices: controller.printerEndpoint.pairedDevices,
                status: controller.printerEndpoint.status.value,
                selectedName: controller.printerEndpoint.selectedName,
                onConnect: controller.connectPrinter,
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
    required this.devices,
    required this.status,
    required this.selectedName,
    required this.onConnect,
  });

  final List<BluetoothDevice> devices;
  final String status;
  final String? selectedName;
  final Future<void> Function(BluetoothDevice device) onConnect;

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
        if (devices.isEmpty) const Text('No paired Bluetooth devices found.'),
        ...devices.map(
          (device) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(device.name),
            subtitle: Text(device.address),
            trailing: TextButton(
              onPressed: () => onConnect(device),
              child: const Text('Connect'),
            ),
          ),
        ),
      ],
    );
  }
}
