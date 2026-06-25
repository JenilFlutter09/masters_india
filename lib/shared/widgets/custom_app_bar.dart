import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/bluetooth_device_service.dart';
import '../../core/services/printer_service.dart';
import '../../core/services/scale_service.dart';
import 'device_connection_bottom_sheet.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.onRefresh,
    this.showDrawer = true,
    super.key,
  });

  final String title;
  final VoidCallback? onRefresh;
  final bool showDrawer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();
    final bluetoothService = Get.find<BluetoothDeviceService>();
    final scaleService = Get.find<ScaleService>();
    final printerService = Get.find<PrinterService>();

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 68,
      titleSpacing: showDrawer ? 4 : 16,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.92),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A14325B),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
      ),
      leading: showDrawer
          ? Builder(
              builder: (context) => IconButton(
                tooltip: 'Open menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
              ),
            )
          : null,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      actions: [
        if (onRefresh != null)
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        Obx(
          () => _StatusButton(
            tooltip: 'Scale Connection',
            icon: Icons.scale_rounded,
            connected: scaleService.isScaleConnected,
            onPressed: () async {
              if (scaleService.isScaleConnected) {
                final confirmed = await _showConfirmDialog(
                  context: context,
                  title: 'Disconnect scale?',
                  message:
                      'This will stop live weight capture from the floor scale.',
                );
                if (confirmed == true) {
                  await bluetoothService
                      .endpoint(DeviceRole.scale)
                      .disconnectAndForget();
                }
                return;
              }
              await showScaleConnectionSheet(context);
            },
          ),
        ),
        Obx(
          () => _StatusButton(
            tooltip: 'Printer Connection',
            icon: Icons.print_rounded,
            connected: printerService.isPrinterConnected,
            onPressed: () async {
              if (printerService.isPrinterConnected) {
                final confirmed = await _showConfirmDialog(
                  context: context,
                  title: 'Disconnect printer?',
                  message:
                      'This will stop label printing until the printer is reconnected.',
                );
                if (confirmed == true) {
                  await printerService.disconnectPrinter();
                }
                return;
              }
              await showPrinterConnectionSheet(context);
            },
          ),
        ),
        IconButton(
          tooltip: 'User Details',
          onPressed: () => _showUserDetailsDialog(context, authService),
          icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
        ),
        IconButton(
          tooltip: 'Logout',
          onPressed: () async {
            final confirmed = await _showConfirmDialog(
              context: context,
              title: 'Logout?',
              message: 'You will need to sign in again to continue.',
            );
            if (confirmed == true) {
              await authService.logout();
              Get.offAllNamed(AppRoutes.login);
            }
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context, AuthService authService) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: 'Name',
                value: authService.userName.value ?? 'Operator',
              ),
              _DetailRow(
                label: 'Email',
                value: authService.userEmail.value ?? '-',
              ),
              _DetailRow(
                label: 'User ID',
                value: authService.userId.value?.toString() ?? '-',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.tooltip,
    required this.icon,
    required this.connected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool connected;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () async {
        await onPressed();
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: connected
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFE76F51),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
