import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/bluetooth_device_service.dart';
import '../../core/services/printer_service.dart';
import '../../core/services/scale_service.dart';
import 'device_connection_bottom_sheet.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();
    final bluetoothService = Get.find<BluetoothDeviceService>();
    final scaleService = Get.find<ScaleService>();
    final printerService = Get.find<PrinterService>();
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width < 640 ? width * 0.82 : 360,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.88),
                  ],
                ),
              ),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.factory_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      authService.userName.value?.trim().isNotEmpty == true
                          ? authService.userName.value!
                          : 'MastersIndia Operator',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authService.userEmail.value ?? 'Scrap-to-coil operations',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                children: [
                  _SectionTitle(title: 'Device Connections'),
                  const SizedBox(height: 8),
                  Obx(
                    () => _ConnectionTile(
                      icon: Icons.scale_rounded,
                      title: 'Scale',
                      subtitle: scaleService.isScaleConnected
                          ? scaleService.deviceStatus
                          : 'Tap to connect the floor scale',
                      connected: scaleService.isScaleConnected,
                      onTap: () async {
                        if (scaleService.isScaleConnected) {
                          await bluetoothService
                              .endpoint(DeviceRole.scale)
                              .disconnect();
                        } else {
                          await showScaleConnectionSheet(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => _ConnectionTile(
                      icon: Icons.print_rounded,
                      title: 'Printer',
                      subtitle: printerService.isPrinterConnected
                          ? printerService.deviceStatus
                          : 'Tap to connect the label printer',
                      connected: printerService.isPrinterConnected,
                      onTap: () async {
                        if (printerService.isPrinterConnected) {
                          await printerService.disconnectPrinter();
                        } else {
                          await showPrinterConnectionSheet(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(title: 'Navigation'),
                  const SizedBox(height: 8),
                  ..._drawerItems.map(
                    (item) => _DrawerItem(
                      label: item.label,
                      icon: item.icon,
                      route: item.route,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authService.logout();
                    Get.offAllNamed(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.connected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool connected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: connected
                      ? const Color(0xFFEAF7EE)
                      : const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  connected ? 'Connected' : 'Connect',
                  style: TextStyle(
                    color: connected
                        ? Colors.green.shade700
                        : const Color(0xFFB96A12),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.offNamed(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerDestination {
  const _DrawerDestination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

const _drawerItems = [
  _DrawerDestination(
    'Dashboard',
    Icons.dashboard_customize_outlined,
    AppRoutes.dashboard,
  ),
  _DrawerDestination(
    'Truck Entry',
    Icons.local_shipping_outlined,
    AppRoutes.truckEntry,
  ),
  _DrawerDestination(
    'Truck Exit',
    Icons.move_to_inbox_outlined,
    AppRoutes.truckExit,
  ),
  _DrawerDestination(
    'Scrap Weighing',
    Icons.scale_outlined,
    AppRoutes.scrapWeighing,
  ),
  _DrawerDestination(
    'Dross Weighing',
    Icons.qr_code_2_outlined,
    AppRoutes.drossWeighing,
  ),
  _DrawerDestination(
    'Line Output',
    Icons.output_outlined,
    AppRoutes.lineOutput,
  ),
  _DrawerDestination(
    'Mother Coil Dispatch',
    Icons.inventory_2_outlined,
    AppRoutes.motherCoilDispatch,
  ),
  _DrawerDestination(
    'Baby Inward',
    Icons.widgets_outlined,
    AppRoutes.babyInward,
  ),
  _DrawerDestination(
    'Baby Product Dispatch',
    Icons.sell_outlined,
    AppRoutes.babyProductDispatch,
  ),
  _DrawerDestination(
    'Scrap Generation',
    Icons.recycling_outlined,
    AppRoutes.scrapGeneration,
  ),
  _DrawerDestination(
    'Dross Outward',
    Icons.outbox_outlined,
    AppRoutes.drossOutward,
  ),
  _DrawerDestination('Settings', Icons.settings_outlined, AppRoutes.settings),
];
