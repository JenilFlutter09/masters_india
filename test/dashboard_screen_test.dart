import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:mastersindia/core/services/bluetooth_device_service.dart';
import 'package:mastersindia/core/services/printer_service.dart';
import 'package:mastersindia/core/services/scale_service.dart';
import 'package:mastersindia/features/dashboard/presentation/dashboard_controller.dart';
import 'package:mastersindia/features/dashboard/presentation/dashboard_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('dashboard renders operation sections and welcome content', (
    tester,
  ) async {
    await bootstrapTestBindings();
    final context = await createTestContext();
    context.authService.userEmail.value = 'admin@example.com';
    context.authService.userName.value = 'Admin User';

    final repository = FakeInventoryRepository(
      apiClient: context.apiClient,
      appConfigService: context.appConfigService,
    );
    final bluetoothService = BluetoothDeviceService(context.storageService);

    Get.put(context.authService);
    Get.put(bluetoothService);
    Get.put(ScaleService(bluetoothService));
    Get.put(PrinterService(bluetoothService));
    Get.put(
      DashboardController(
        inventoryRepository: repository,
        inventoryCacheService: context.inventoryCacheService,
        authService: context.authService,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Inventory Dashboard'), findsOneWidget);
    expect(find.text('Welcome, Admin User'), findsOneWidget);
    expect(find.text('Inventory Snapshot'), findsOneWidget);
    expect(find.text('SCRAP'), findsOneWidget);
    expect(find.text('1200'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('support operations keeps a two-column grid on tablet layout', (
    tester,
  ) async {
    await bootstrapTestBindings();
    final context = await createTestContext();
    context.authService.userEmail.value = 'admin@example.com';
    context.authService.userName.value = 'Admin User';

    final repository = FakeInventoryRepository(
      apiClient: context.apiClient,
      appConfigService: context.appConfigService,
    );
    final bluetoothService = BluetoothDeviceService(context.storageService);

    Get.put(context.authService);
    Get.put(bluetoothService);
    Get.put(ScaleService(bluetoothService));
    Get.put(PrinterService(bluetoothService));
    Get.put(
      DashboardController(
        inventoryRepository: repository,
        inventoryCacheService: context.inventoryCacheService,
        authService: context.authService,
      ),
    );

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    final firstTilePosition = tester.getTopLeft(
      find.text('Mother Coil Dispatch'),
    );
    final secondTilePosition = tester.getTopLeft(find.text('Baby Inward'));

    expect(firstTilePosition.dy, secondTilePosition.dy);
    expect(secondTilePosition.dx, greaterThan(firstTilePosition.dx));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
