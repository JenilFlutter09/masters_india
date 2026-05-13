import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_banner.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.refreshInventory,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(() {
        final summaryEntries = controller.balances.take(5).toList();
        final primaryActions = [
          _DashboardAction(
            title: 'Truck Entry',
            subtitle: 'Capture loaded truck weight and inward details.',
            icon: Icons.local_shipping_outlined,
            onTap: () => Get.toNamed(AppRoutes.truckEntry),
          ),
          _DashboardAction(
            title: 'Truck Exit',
            subtitle: 'Capture empty truck exit against receipt or invoice.',
            icon: Icons.move_to_inbox_outlined,
            onTap: () => Get.toNamed(AppRoutes.truckExit),
          ),
          _DashboardAction(
            title: 'Scrap Weighing',
            subtitle: 'Register scrap inward and inventory increment.',
            icon: Icons.scale_outlined,
            onTap: () => Get.toNamed(AppRoutes.scrapWeighing),
          ),
          _DashboardAction(
            title: 'Dross Weighing',
            subtitle: 'Capture dross and print a barcode label.',
            icon: Icons.qr_code_2_outlined,
            onTap: () => Get.toNamed(AppRoutes.drossWeighing),
          ),
          _DashboardAction(
            title: 'Line Input Weighing',
            subtitle: 'Move scrap into furnace WIP with from/to tracking.',
            icon: Icons.input_outlined,
            onTap: () => Get.toNamed(AppRoutes.lineInput),
          ),
          _DashboardAction(
            title: 'Line Output Weighing',
            subtitle: 'Create rods or sheets and mother coil barcodes.',
            icon: Icons.output_outlined,
            onTap: () => Get.toNamed(AppRoutes.lineOutput),
          ),
        ];
        final supportActions = [
          _DashboardAction(
            title: 'Mother Coil Dispatch',
            subtitle: 'Dispatch conversion stock and set baby cap.',
            icon: Icons.inventory_2_outlined,
            onTap: () => Get.toNamed(AppRoutes.motherCoilDispatch),
          ),
          _DashboardAction(
            title: 'Baby Inward',
            subtitle: 'Create baby items and barcode labels.',
            icon: Icons.widgets_outlined,
            onTap: () => Get.toNamed(AppRoutes.babyInward),
          ),
          _DashboardAction(
            title: 'Baby Product Dispatch',
            subtitle: 'Dispatch baby product by barcode.',
            icon: Icons.sell_outlined,
            onTap: () => Get.toNamed(AppRoutes.babyProductDispatch),
          ),
          _DashboardAction(
            title: 'Scrap Generation',
            subtitle: 'Record furnace return scrap by line.',
            icon: Icons.recycling_outlined,
            onTap: () => Get.toNamed(AppRoutes.scrapGeneration),
          ),
          _DashboardAction(
            title: 'Dross Outward',
            subtitle: 'Record dross outward movements.',
            icon: Icons.outbox_outlined,
            onTap: () => Get.toNamed(AppRoutes.drossOutward),
          ),
        ];
        final dashboardHighlights = [
          '${primaryActions.length + supportActions.length} workflows',
          summaryEntries.isEmpty
              ? 'Inventory sync pending'
              : '${summaryEntries.length} inventory buckets',
          controller.recentTransactions.isEmpty
              ? 'No recent activity'
              : '${controller.recentTransactions.take(5).length} recent events',
        ];

        return LoadingOverlay(
          visible: controller.isLoading.value && controller.balances.isEmpty,
          message: 'Loading inventory...',
          child: RefreshIndicator(
            onRefresh: controller.refreshInventory,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEFF5FD),
                    Color(0xFFF7FAFE),
                    Color(0xFFF3F7FC),
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth >= 980;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1480),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 24 : 16,
                          isTablet ? 20 : 16,
                          isTablet ? 24 : 16,
                          28,
                        ),
                        children: [
                          // _DashboardHeader(
                          //   title:
                          //       'Welcome, ${controller.userName.isEmpty ? controller.userEmail : controller.userName}',
                          //   subtitle:
                          //       'Track inward, furnace, and dispatch activity from one floor-ready console.',
                          //   highlights: dashboardHighlights,
                          // ),
                          const SizedBox(height: 16),
                          if (controller.errorMessage.value != null)
                            StatusBanner(
                              message: controller.errorMessage.value!,
                              isError: true,
                            ),
                          if (controller.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: LinearProgressIndicator(),
                            ),
                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                 // flex: 12,
                                  child: Column(
                                    children: [
                                      SectionCard(
                                        title: 'Primary Operations',
                                        subtitle:
                                            'Core floor activities operators use throughout the shift.',
                                        child: _ActionGrid(
                                          actions: primaryActions,
                                          crossAxisCount: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                 // flex: 9,
                                  child: Column(
                                    children: [
                                      SectionCard(
                                        title: 'Support Operations',
                                        subtitle:
                                            'Secondary production and dispatch workflows.',
                                        child: _ActionGrid(
                                          actions: supportActions,
                                          crossAxisCount: 2,
                                        ),
                                      ),
                                      SectionCard(
                                        title: 'Recent Activity',
                                        subtitle:
                                            'Most recent backend events available in the current session.',
                                        child: _RecentActivityList(
                                          items: controller.recentTransactions,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            SectionCard(
                              title: 'Primary Operations',
                              subtitle:
                                  'Core floor activities operators use throughout the shift.',
                              child: _ActionGrid(actions: primaryActions),
                            ),
                            SectionCard(
                              title: 'Support Operations',
                              subtitle:
                                  'Secondary production and dispatch workflows.',
                              child: _ActionGrid(actions: supportActions),
                            ),
                            SectionCard(
                              title: 'Recent Activity',
                              subtitle:
                                  'Most recent backend events available in the current session.',
                              child: _RecentActivityList(
                                items: controller.recentTransactions,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.title,
    required this.subtitle,
    this.highlights = const [],
  });

  final String title;
  final String subtitle;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF4F8FE)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D163A66),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.factory_outlined,
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: highlights
                  .map((highlight) => _DashboardHighlightChip(label: highlight))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardHighlightChip extends StatelessWidget {
  const _DashboardHighlightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions, this.crossAxisCount});

  final List<_DashboardAction> actions;
  final int? crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedCrossAxisCount =
            crossAxisCount ?? (constraints.maxWidth >= 460 ? 2 : 1);
        final isWide = resolvedCrossAxisCount > 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: resolvedCrossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: isWide ? 122 : 114,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final item = actions[index];
            return ActionTile(
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              onTap: item.onTap,
            );
          },
        );
      },
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Text(
        'No recent transactions returned by the backend yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: items.take(5).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']?.toString() ??
                          item['type']?.toString() ??
                          'Workflow event',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['message']?.toString() ?? item.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
