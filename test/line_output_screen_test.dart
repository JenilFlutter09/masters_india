import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:mastersindia/core/services/bluetooth_device_service.dart';
import 'package:mastersindia/core/services/printer_service.dart';
import 'package:mastersindia/core/services/scale_service.dart';
import 'package:mastersindia/features/line_output/presentation/line_output_controller.dart';
import 'package:mastersindia/features/line_output/presentation/line_output_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('line output shows the API-aligned furnace output fields', (
    tester,
  ) async {
    await bootstrapTestBindings();
    final context = await createTestContext();
    context.authService.userEmail.value = 'admin@example.com';
    context.authService.userName.value = 'Admin User';
    final bluetoothService = BluetoothDeviceService(context.storageService);
    final scaleService = ScaleService(bluetoothService);
    final printerService = PrinterService(bluetoothService);

    Get.put(context.authService);
    Get.put(bluetoothService);
    Get.put(scaleService);
    Get.put(printerService);
    Get.put(context.masterDataRepository);

    final controller = Get.put(
      LineOutputController(
        workflowRepository: context.workflowRepository,
        scaleService: scaleService,
        printerService: printerService,
      ),
    );

    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: LineOutputScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Production Line'), findsOneWidget);
    expect(find.text('Mother Coil Product'), findsOneWidget);
    expect(find.text('Metal Alloy'), findsOneWidget);
    expect(find.text('GROSS WEIGHT'), findsOneWidget);
    expect(find.text('TARE WEIGHT'), findsOneWidget);

    expect(find.text('Production Type'), findsNothing);
    expect(find.text('Produced At'), findsNothing);
    expect(find.text('Label Printed At'), findsNothing);
    expect(find.text('CCTV Reference'), findsNothing);
    expect(controller.selectedMotherCoilProductId.value, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
