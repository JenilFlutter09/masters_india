import 'package:get/get.dart';

import '../models/label_job.dart';
import 'bluetooth_device_service.dart';

class PrinterService extends GetxService {
  PrinterService(BluetoothDeviceService bluetoothDeviceService)
    : _bluetoothDeviceService = bluetoothDeviceService,
      _mockStatus = 'Not connected',
      _mockConfigured = false,
      _mockConnected = false;

  PrinterService.test({
    String mockStatus = 'Test printer idle',
    bool mockConfigured = false,
    bool mockConnected = false,
  }) : _bluetoothDeviceService = null,
       _mockStatus = mockStatus,
       _mockConfigured = mockConfigured,
       _mockConnected = mockConnected;

  final BluetoothDeviceService? _bluetoothDeviceService;
  final String _mockStatus;
  final bool _mockConfigured;
  final bool _mockConnected;

  bool get isPrinterConfigured =>
      _bluetoothDeviceService?.endpoint(DeviceRole.printer).selectedAddress !=
          null ||
      _mockConfigured;

  bool get isPrinterConnected =>
      _bluetoothDeviceService?.endpoint(DeviceRole.printer).isConnected.value ??
      _mockConnected;

  String get deviceStatus =>
      _bluetoothDeviceService?.endpoint(DeviceRole.printer).status.value ??
      _mockStatus;

  Future<bool> printLabel(LabelJob job) {
    final buffer = StringBuffer()
      ..writeln(job.title.toUpperCase())
      ..writeln('--------------------------');
    for (final line in job.lines) {
      buffer.writeln(line);
    }
    if (job.barcodeValue != null && job.barcodeValue!.isNotEmpty) {
      buffer
        ..writeln('--------------------------')
        ..writeln('BARCODE:${job.barcodeValue}');
    }
    buffer.writeln();
    return _bluetoothDeviceService
            ?.endpoint(DeviceRole.printer)
            .sendString(buffer.toString()) ??
        Future.value(true);
  }

  LabelJob buildDrossLabel({
    required Map<String, dynamic> request,
    required Map<String, dynamic> response,
  }) {
    final result =
        (response['data'] as Map?)?.cast<String, dynamic>() ?? response;
    final barcode =
        result['dross_ref']?.toString() ??
        result['barcode']?.toString() ??
        result['dross_barcode']?.toString() ??
        result['id']?.toString();
    return LabelJob(
      title: 'Dross Label',
      barcodeValue: barcode,
      lines: [
        'Line ID: ${request['production_line_id'] ?? '-'}',
        'Type: ${request['dross_type'] ?? '-'}',
        'Weight: ${request['weight'] ?? '-'} kg',
      ],
    );
  }

  LabelJob buildMotherCoilLabel({
    required Map<String, dynamic> request,
    required Map<String, dynamic> response,
  }) {
    final result =
        (response['data'] as Map?)?.cast<String, dynamic>() ?? response;
    final barcode =
        result['mother_coil_barcode']?.toString() ??
        result['barcode']?.toString() ??
        result['coil_id']?.toString();
    return LabelJob(
      title: 'Mother Coil Label',
      barcodeValue: barcode,
      lines: [
        'Type: ${request['production_type'] ?? '-'}',
        'Weight: ${request['issue_weight'] ?? request['weight'] ?? '-'} kg',
        'Alloy ID: ${request['metal_alloy_id'] ?? '-'}',
      ],
    );
  }
}
