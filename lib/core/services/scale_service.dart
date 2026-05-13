import 'dart:async';

import 'package:get/get.dart';

import '../models/scale_reading.dart';
import 'bluetooth_device_service.dart';

class ScaleService extends GetxService {
  ScaleService(BluetoothDeviceService bluetoothDeviceService)
    : _bluetoothDeviceService = bluetoothDeviceService,
      _mockStatus = 'Not connected',
      _mockConfigured = false,
      _mockConnected = false;

  ScaleService.test({
    ScaleReading? initialReading,
    String mockStatus = 'Test scale idle',
    bool mockConfigured = false,
    bool mockConnected = false,
  }) : _bluetoothDeviceService = null,
       _mockStatus = mockStatus,
       _mockConfigured = mockConfigured,
       _mockConnected = mockConnected {
    currentReading.value = initialReading;
  }

  final BluetoothDeviceService? _bluetoothDeviceService;
  final String _mockStatus;
  final bool _mockConfigured;
  final bool _mockConnected;
  final currentReading = Rxn<ScaleReading>();
  StreamSubscription<dynamic>? _subscription;
  double? _lastWeight;

  @override
  void onInit() {
    super.onInit();
    if (_bluetoothDeviceService != null) {
      _subscription = _bluetoothDeviceService
          .dataStream(DeviceRole.scale)
          .listen((data) => parseAndStore(data.asString()));
    }
  }

  bool get isScaleConfigured =>
      _bluetoothDeviceService?.endpoint(DeviceRole.scale).selectedAddress !=
          null ||
      _mockConfigured;

  bool get isScaleConnected =>
      _bluetoothDeviceService?.endpoint(DeviceRole.scale).isConnected.value ??
      _mockConnected;

  String get deviceStatus =>
      _bluetoothDeviceService?.endpoint(DeviceRole.scale).status.value ??
      _mockStatus;

  void parseAndStore(String raw) {
    final reading = parseReading(raw, _lastWeight);
    if (reading != null) {
      _lastWeight = reading.weight;
      currentReading.value = reading;
    }
  }

  static ScaleReading? parseReading(String raw, [double? lastWeight]) {
    final match = RegExp(r'(-?\d+(?:\.\d+)?)').firstMatch(raw);
    if (match == null) {
      return null;
    }

    final weight = double.tryParse(match.group(1)!);
    if (weight == null) {
      return null;
    }

    final normalized = raw.toLowerCase();
    final isStable =
        normalized.contains('st') ||
        normalized.contains('stable') ||
        (lastWeight != null && weight == lastWeight);
    final unit = normalized.contains('kg') ? 'kg' : 'unit';

    return ScaleReading(
      raw: raw,
      weight: weight,
      unit: unit,
      isStable: isStable,
      capturedAt: DateTime.now(),
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
