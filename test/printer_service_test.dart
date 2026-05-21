import 'package:flutter_test/flutter_test.dart';

import 'package:mastersindia/core/services/printer_service.dart';

import 'helpers/test_services.dart';

void main() {
  test('printer service builds dross and mother coil labels', () async {
    await bootstrapTestBindings();
    final printer = PrinterService.test();

    final drossLabel = printer.buildDrossLabel(
      request: {
        'production_line_id': 7,
        'dross_type': 'Hot dross',
        'weight': 18.5,
      },
      response: {
        'data': {'dross_ref': 'DRS-1001'},
      },
    );
    final motherCoilLabel = printer.buildMotherCoilLabel(
      request: {
        'mother_coil_product_name': 'Rod',
        'gross_weight': 540,
        'metal_alloy_id': 3,
      },
      response: {
        'data': {'mother_coil_barcode': 'MC-2201'},
      },
    );

    expect(drossLabel.barcodeValue, 'DRS-1001');
    expect(drossLabel.lines.first, contains('7'));
    expect(motherCoilLabel.barcodeValue, 'MC-2201');
    expect(motherCoilLabel.lines.join(' '), contains('Rod'));
  });
}
