import 'package:flutter_test/flutter_test.dart';

import 'package:mastersindia/core/services/scale_service.dart';

void main() {
  test('scale parser extracts stable kilogram reading', () {
    final reading = ScaleService.parseReading('ST, 1250.50 kg', 1250.50);

    expect(reading, isNotNull);
    expect(reading!.weight, 1250.50);
    expect(reading.unit, 'kg');
    expect(reading.isStable, isTrue);
  });
}
