import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:get/get.dart';

import '../../core/services/bluetooth_device_service.dart';
import '../../core/services/printer_service.dart';
import '../../core/services/scale_service.dart';

Future<void> showScaleConnectionSheet(BuildContext context) async {
  final bluetoothService = Get.find<BluetoothDeviceService>();
  final scaleEndpoint = bluetoothService.endpoint(DeviceRole.scale);

  await scaleEndpoint.loadPairedDevices();
  if (!context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DeviceConnectionSheet(
      title: 'Scale Connection',
      subtitle: 'Connect the paired floor scale used for live weight capture.',
      emptyMessage:
          'No paired scale found. Pair the device in Android Bluetooth settings first.',
      role: DeviceRole.scale,
      onRefresh: scaleEndpoint.loadPairedDevices,
    ),
  );
}

Future<void> showPrinterConnectionSheet(BuildContext context) async {
  final bluetoothService = Get.find<BluetoothDeviceService>();
  final printerEndpoint = bluetoothService.endpoint(DeviceRole.printer);

  await printerEndpoint.loadPairedDevices();
  if (!context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DeviceConnectionSheet(
      title: 'Printer Connection',
      subtitle:
          'Connect the SNBC label printer used for dross, mother coil, and baby labels.',
      emptyMessage:
          'No paired printer found. Pair the printer in Android Bluetooth settings first.',
      role: DeviceRole.printer,
      onRefresh: printerEndpoint.loadPairedDevices,
    ),
  );
}

class _DeviceConnectionSheet extends StatelessWidget {
  const _DeviceConnectionSheet({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.role,
    required this.onRefresh,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final DeviceRole role;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bluetoothService = Get.find<BluetoothDeviceService>();
    final printerService = Get.find<PrinterService>();
    final scaleService = Get.find<ScaleService>();
    final endpoint = bluetoothService.endpoint(role);
    final isScale = role == DeviceRole.scale;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.76,
          minHeight: MediaQuery.of(context).size.height * 0.42,
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Obx(() {
          final devices = endpoint.pairedDevices.toList(growable: false);
          final status = isScale
              ? scaleService.deviceStatus
              : printerService.deviceStatus;
          final isConnected = isScale
              ? scaleService.isScaleConnected
              : printerService.isPrinterConnected;
          final selectedAddress = endpoint.selectedAddress;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isScale ? Icons.scale_rounded : Icons.print_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh devices',
                    onPressed: () async {
                      await onRefresh();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.check_circle_rounded
                          : Icons.bluetooth_searching_rounded,
                      color: isConnected
                          ? Colors.green.shade700
                          : theme.colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        status,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (devices.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final isSelected = selectedAddress == device.address;
                      return _DeviceTile(
                        device: device,
                        icon: isScale
                            ? Icons.scale_rounded
                            : Icons.print_rounded,
                        connected: isConnected && isSelected,
                        selected: isSelected,
                        onPressed: () async {
                          final success = isScale
                              ? await endpoint.connect(device)
                              : await printerService.connectPrinter(device);
                          if (!context.mounted) {
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.hideCurrentSnackBar();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '${device.name} connected.'
                                    : 'Unable to connect ${device.name}.',
                              ),
                            ),
                          );
                          if (success) {
                            Navigator.of(context).pop();
                          }
                        },
                        onDisconnect: (isConnected && isSelected)
                            ? () async {
                                final success = isScale
                                    ? await endpoint.disconnect()
                                    : await printerService.disconnectPrinter();
                                if (!context.mounted) {
                                  return;
                                }
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.hideCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '${device.name} disconnected.'
                                          : 'Unable to disconnect ${device.name}.',
                                    ),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.icon,
    required this.connected,
    required this.selected,
    required this.onPressed,
    this.onDisconnect,
  });

  final BluetoothDevice device;
  final IconData icon;
  final bool connected;
  final bool selected;
  final Future<void> Function() onPressed;
  final Future<void> Function()? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: connected
            ? const Color(0xFFF1F8F3)
            : selected
            ? const Color(0xFFF6F8FC)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (connected && onDisconnect != null)
            TextButton(
              onPressed: () async {
                await onDisconnect!();
              },
              child: const Text('Disconnect'),
            )
          else
            ElevatedButton(
              onPressed: () async {
                await onPressed();
              },
              child: Text(selected ? 'Reconnect' : 'Connect'),
            ),
        ],
      ),
    );
  }
}
