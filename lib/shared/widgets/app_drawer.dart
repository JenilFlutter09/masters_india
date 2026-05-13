import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: const [
            _DrawerHeader(),
            _DrawerItem(
              'Dashboard',
              Icons.dashboard_customize_outlined,
              AppRoutes.dashboard,
            ),
            _DrawerItem(
              'Truck Entry',
              Icons.local_shipping_outlined,
              AppRoutes.truckEntry,
            ),
            _DrawerItem(
              'Truck Exit',
              Icons.move_to_inbox_outlined,
              AppRoutes.truckExit,
            ),
            _DrawerItem(
              'Scrap Weighing',
              Icons.scale_outlined,
              AppRoutes.scrapWeighing,
            ),
            _DrawerItem(
              'Dross Weighing',
              Icons.qr_code_2_outlined,
              AppRoutes.drossWeighing,
            ),
            _DrawerItem(
              'Line Input',
              Icons.input_outlined,
              AppRoutes.lineInput,
            ),
            _DrawerItem(
              'Line Output',
              Icons.output_outlined,
              AppRoutes.lineOutput,
            ),
            _DrawerItem(
              'Mother Coil Dispatch',
              Icons.local_shipping_outlined,
              AppRoutes.motherCoilDispatch,
            ),
            _DrawerItem(
              'Baby Inward',
              Icons.inventory_2_outlined,
              AppRoutes.babyInward,
            ),
            _DrawerItem(
              'Baby Product Dispatch',
              Icons.sell_outlined,
              AppRoutes.babyProductDispatch,
            ),
            _DrawerItem(
              'Scrap Generation',
              Icons.recycling_outlined,
              AppRoutes.scrapGeneration,
            ),
            _DrawerItem(
              'Dross Outward',
              Icons.outbox_outlined,
              AppRoutes.drossOutward,
            ),
            _DrawerItem(
              'Settings',
              Icons.settings_outlined,
              AppRoutes.settings,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MastersIndia',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Scrap-to-coil operations',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => Get.offNamed(route),
    );
  }
}
