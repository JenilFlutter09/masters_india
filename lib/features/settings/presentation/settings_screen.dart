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
        () => LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 980;
            final contentWidth = isTablet ? 1200.0 : 760.0;
            final topInset = MediaQuery.of(context).padding.top;

            final backendCard = SectionCard(
              title: 'Backend Configuration',
              subtitle:
                  'Point the app to the correct MastersIndia environment before operators begin work.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsFieldRow(
                    children: [
                      AppTextField(
                        label: 'Base URL',
                        controller: controller.baseUrlController,
                      ),
                      AppTextField(
                        label: 'Login Path',
                        controller: controller.loginPathController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveConfig,
                      icon: const Icon(Icons.cloud_done_outlined),
                      label: Text(
                        controller.isSaving.value
                            ? 'Saving Configuration...'
                            : 'Save Configuration',
                      ),
                    ),
                  ),
                ],
              ),
            );

            final devicesCard = SectionCard(
              title: 'Connected Hardware',
              subtitle:
                  'Manage the weighing scale and SNBC label printer used on the floor.',
              child: Column(
                children: [
                  _DevicePanel(
                    title: 'Scale Device',
                    description:
                        'Pair the floor scale through Android Bluetooth first, then connect it here.',
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
                    icon: Icons.scale_rounded,
                  ),
                  const SizedBox(height: 14),
                  _DevicePanel(
                    title: 'Printer Device',
                    description:
                        'Connect the SNBC label printer used for dross, mother coil, and baby-product labels.',
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
                    icon: Icons.print_rounded,
                  ),
                ],
              ),
            );

            final diagnosticsCard = SectionCard(
              title: 'Diagnostics & Actions',
              subtitle:
                  'Run quick checks for scale data, printer output, and device availability.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionGrid(
                    actions: [
                      _ActionSpec(
                        label: 'Refresh Devices',
                        icon: Icons.refresh_rounded,
                        onTap: controller.refreshDevices,
                      ),
                      _ActionSpec(
                        label: 'Test Scale Read',
                        icon: Icons.sensors_outlined,
                        onTap: controller.testScaleRead,
                      ),
                      _ActionSpec(
                        label: 'Test Print',
                        icon: Icons.print_outlined,
                        onTap: controller.testPrint,
                      ),
                      _ActionSpec(
                        label: 'Logout',
                        icon: Icons.logout_rounded,
                        onTap: controller.logout,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            );

            final bodyChildren = [
              if (controller.feedback.value != null)
                StatusBanner(
                  message: controller.feedback.value!,
                  isError: false,
                ),
              _SettingsHero(
                scaleConnected: controller.scaleService.isScaleConnected,
                printerConnected: controller.printerService.isPrinterConnected,
                scaleName: controller.scaleEndpoint.selectedName,
                printerName: controller.printerService.selectedPrinterName,
              ),
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(children: [backendCard, diagnosticsCard]),
                    ),
                    const SizedBox(width: 18),
                    Expanded(child: devicesCard),
                  ],
                )
              else ...[
                backendCard,
                devicesCard,
                diagnosticsCard,
              ],
            ];

            return RefreshIndicator(
              onRefresh: controller.refreshDevices,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bodyChildren,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.scaleConnected,
    required this.printerConnected,
    required this.scaleName,
    required this.printerName,
  });

  final bool scaleConnected;
  final bool printerConnected;
  final String? scaleName;
  final String? printerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22163A66),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.settings_suggest_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Operations Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep device connections, backend routing, and diagnostics ready for both floor operators and supervisors.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatusChip(
                label: scaleConnected
                    ? 'Scale online${scaleName == null ? '' : ' • $scaleName'}'
                    : 'Scale offline',
              ),
              _HeroStatusChip(
                label: printerConnected
                    ? 'Printer online${printerName == null ? '' : ' • $printerName'}'
                    : 'Printer offline',
              ),
              const _HeroStatusChip(label: 'Tablet-ready layout'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatusChip extends StatelessWidget {
  const _HeroStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DevicePanel extends StatelessWidget {
  const _DevicePanel({
    required this.title,
    required this.description,
    required this.status,
    required this.selectedName,
    required this.actionLabel,
    required this.onPressed,
    required this.icon,
    this.isConnected = false,
  });

  final String title;
  final String description;
  final String status;
  final String? selectedName;
  final String actionLabel;
  final Future<void> Function() onPressed;
  final IconData icon;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ConnectionBadge(isConnected: isConnected),
            ],
          ),
          const SizedBox(height: 16),
          _DeviceInfoRow(label: 'Status', value: status),
          _DeviceInfoRow(
            label: 'Selected Device',
            value: selectedName ?? 'No device selected',
          ),
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
                  ? 'The active device is connected and ready for operations.'
                  : 'Open the shared device sheet to choose a paired device for this station.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
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
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFEAF7EE) : const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isConnected ? 'Connected' : 'Offline',
        style: TextStyle(
          color: isConnected ? Colors.green.shade700 : const Color(0xFFB96A12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeviceInfoRow extends StatelessWidget {
  const _DeviceInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<_ActionSpec> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 2 : 1;
        final spacing = 12.0;
        final tileWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
            crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions
              .map(
                (action) => SizedBox(
                  width: tileWidth,
                  child: _ActionTile(action: action),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final _ActionSpec action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = action.isDestructive
        ? const Color(0xFFB42318)
        : theme.colorScheme.primary;
    final containerColor = action.isDestructive
        ? const Color(0xFFFFF1F1)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.55);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSpec {
  const _ActionSpec({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _SettingsFieldRow extends StatelessWidget {
  const _SettingsFieldRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(children: children);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}
