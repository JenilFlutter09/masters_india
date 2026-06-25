import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mastersindia/core/services/bluetooth_device_service.dart';
import 'package:mastersindia/core/services/printer_service.dart';
import 'package:mastersindia/core/services/scale_service.dart';
import 'package:mastersindia/features/dispatch/presentation/baby_inward_controller.dart';
import 'package:mastersindia/features/dispatch/presentation/baby_inward_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('baby inward renders selected product parameter fields', (
    tester,
  ) async {
    await bootstrapTestBindings();
    final context = await createTestContext(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/masters/mother-coils-available')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 1,
                  'coil_no': 'MC-001',
                  'barcode': 'MC001',
                  'product_name': 'iron',
                  'remaining_weight': 10,
                },
              ],
            }),
            200,
          );
        }

        if (request.url.path.endsWith('/masters/baby-coil-products')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 3,
                  'name': 'b1',
                  'product_type': 'baby',
                  'parameters': ['th'],
                },
                {
                  'id': 5,
                  'name': 'b2',
                  'product_type': 'baby',
                  'parameters': ['width', 'height'],
                },
              ],
            }),
            200,
          );
        }

        return http.Response(jsonEncode({'success': true, 'data': []}), 200);
      }),
    );
    final bluetoothService = BluetoothDeviceService(context.storageService);
    final scaleService = ScaleService(bluetoothService);
    final printerService = PrinterService(bluetoothService);

    Get.put(context.authService);
    Get.put(bluetoothService);
    Get.put(scaleService);
    Get.put(printerService);
    Get.put(context.masterDataRepository);

    final controller = Get.put(
      BabyInwardController(
        workflowRepository: context.workflowRepository,
        scaleService: scaleService,
        printerService: printerService,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: BabyInwardScreen()));
    await tester.pumpAndSettle();

    controller.onBabyProductChanged(5);
    await tester.pumpAndSettle();

    expect(find.text('Baby Product Parameters'), findsOneWidget);
    expect(find.text('width'), findsOneWidget);
    expect(find.text('height'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'width'), '12');
    await tester.enterText(find.widgetWithText(TextFormField, 'height'), '24');

    expect(controller.buildParameterValues(), {'width': '12', 'height': '24'});

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
