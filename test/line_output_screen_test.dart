import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:mastersindia/features/line_output/presentation/line_output_controller.dart';
import 'package:mastersindia/features/line_output/presentation/line_output_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('line output toggles between rod and sheet fields', (
    tester,
  ) async {
    await bootstrapTestBindings();
    final context = await createTestContext();
    Get.put(context.masterDataRepository);

    final controller = Get.put(
      LineOutputController(
        workflowRepository: context.workflowRepository,
        scaleService: context.scaleService,
        printerService: context.printerService,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: LineOutputScreen()));

    expect(find.widgetWithText(TextFormField, 'Produced At'), findsOneWidget);
    expect(controller.outputType.value, 'Rod');

    controller.setOutputType('Sheet');
    await tester.pump();

    expect(controller.outputType.value, 'Sheet');
    expect(find.text('Production Type'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
