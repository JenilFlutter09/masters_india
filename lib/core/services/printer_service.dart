import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:get/get.dart';

import '../models/label_job.dart';
import 'bluetooth_device_service.dart';

class PrinterService extends GetxService {
  PrinterService(BluetoothDeviceService bluetoothDeviceService)
    : _bluetoothDeviceService = bluetoothDeviceService,
      _mockStatus = 'Not connected',
      _mockConfigured = false,
      _mockConnected = false,
      _mockStorageSelectionName = null;

  PrinterService.test({
    String mockStatus = 'Test printer idle',
    bool mockConfigured = false,
    bool mockConnected = false,
    String? mockSelectionName,
  }) : _bluetoothDeviceService = null,
       _mockStatus = mockStatus,
       _mockConfigured = mockConfigured,
       _mockConnected = mockConnected,
       _mockStorageSelectionName = mockSelectionName;

  static const _channel = MethodChannel('label_printer');
  final BluetoothDeviceService? _bluetoothDeviceService;
  final String _mockStatus;
  final bool _mockConfigured;
  final bool _mockConnected;
  final String? _mockStorageSelectionName;
  final _deviceStatus = 'Not connected'.obs;
  final _isConnected = false.obs;
  Timer? _statusTimer;
  bool _isReconnectInFlight = false;

  bool get isPrinterConfigured =>
      _bluetoothDeviceService?.endpoint(DeviceRole.printer).selectedAddress !=
          null ||
      _mockConfigured;

  String? get selectedPrinterName =>
      _bluetoothDeviceService?.endpoint(DeviceRole.printer).selectedName ??
      _mockStorageSelectionName;

  bool get isPrinterConnected =>
      _bluetoothDeviceService == null ? _mockConnected : _isConnected.value;

  String get deviceStatus =>
      _bluetoothDeviceService == null ? _mockStatus : _deviceStatus.value;

  Future<void> initialize() async {
    if (_bluetoothDeviceService == null) {
      return;
    }
    await refreshStatus(showDisconnectedFeedback: false);
    await reconnectSavedPrinter();
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(refreshStatus(showDisconnectedFeedback: false));
    });
  }

  Future<bool> connectPrinter(BluetoothDevice device) async {
    return connectPrinterByAddress(
      device.address,
      persistSelection: true,
      device: device,
    );
  }

  Future<bool> connectPrinterByAddress(
    String address, {
    bool persistSelection = true,
    bool showStatusRefresh = true,
    BluetoothDevice? device,
  }) async {
    if (_bluetoothDeviceService == null) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<String>('connectPrinter', {
        'mac': address,
      });
      _isConnected.value = true;
      _deviceStatus.value = result ?? 'Connected';
      if (persistSelection) {
        final endpoint = _bluetoothDeviceService.endpoint(DeviceRole.printer);
        final selectedDevice =
            device ??
            endpoint.pairedDevices.firstWhereOrNull(
              (item) => item.address == address,
            );
        if (selectedDevice != null) {
          await endpoint.saveSelection(selectedDevice);
        }
      }
      if (showStatusRefresh) {
        await refreshStatus(showDisconnectedFeedback: false);
      }
      return true;
    } on PlatformException catch (error) {
      _isConnected.value = false;
      _deviceStatus.value = error.message ?? 'Printer connection failed';
      return false;
    } catch (error) {
      _isConnected.value = false;
      _deviceStatus.value = error.toString();
      return false;
    }
  }

  Future<bool> reconnectSavedPrinter({bool force = false}) async {
    if (_bluetoothDeviceService == null ||
        _isReconnectInFlight ||
        (isPrinterConnected && !force)) {
      return isPrinterConnected;
    }

    final endpoint = _bluetoothDeviceService.endpoint(DeviceRole.printer);
    final selectedAddress = endpoint.selectedAddress;
    if (selectedAddress == null || selectedAddress.isEmpty) {
      return false;
    }

    _isReconnectInFlight = true;
    try {
      await endpoint.loadPairedDevices();
      if (force) {
        await disconnectPrinter(forgetSelection: false);
      }
      return await connectPrinterByAddress(
        selectedAddress,
        persistSelection: false,
        showStatusRefresh: false,
      );
    } finally {
      _isReconnectInFlight = false;
    }
  }

  Future<bool> disconnectPrinter({bool forgetSelection = true}) async {
    if (_bluetoothDeviceService == null) {
      return true;
    }
    try {
      final result = await _channel.invokeMethod<String>('disconnectPrinter');
      _isConnected.value = false;
      _deviceStatus.value = result ?? 'Disconnected';
      if (forgetSelection) {
        await _bluetoothDeviceService
            .endpoint(DeviceRole.printer)
            .clearSelection();
      }
      return true;
    } on PlatformException catch (error) {
      _deviceStatus.value = error.message ?? 'Disconnect failed';
      return false;
    } catch (error) {
      _deviceStatus.value = error.toString();
      return false;
    }
  }

  Future<void> refreshStatus({bool showDisconnectedFeedback = true}) async {
    if (_bluetoothDeviceService == null) {
      return;
    }
    try {
      final status = await _channel.invokeMapMethod<String, dynamic>(
        'getPrinterStatus',
      );
      final connected = status?['connected'] == true;
      _isConnected.value = connected;
      if (!connected) {
        _deviceStatus.value =
            (status?['message']?.toString() ?? 'Disconnected');
        return;
      }

      final issues = <String>[];
      if (status?['is_ready_to_print'] != true) issues.add('Not ready');
      if (status?['is_paper_out'] == true) issues.add('Paper out');
      if (status?['is_head_opened'] == true) issues.add('Head open');
      if (status?['is_ribbon_out'] == true) issues.add('Ribbon out');
      if (status?['is_cutter_error'] == true) issues.add('Cutter error');
      if (status?['is_paused'] == true) issues.add('Paused');
      if (status?['is_printer_busy'] == true) issues.add('Busy');
      _deviceStatus.value = issues.isEmpty
          ? 'Connected'
          : 'Connected • ${issues.join(", ")}';
    } on PlatformException catch (error) {
      if (showDisconnectedFeedback) {
        _deviceStatus.value = error.message ?? 'Printer unavailable';
      }
      _isConnected.value = false;
    } catch (error) {
      if (showDisconnectedFeedback) {
        _deviceStatus.value = error.toString();
      }
      _isConnected.value = false;
    }
  }

  Future<bool> printLabel(LabelJob job) async {
    if (_bluetoothDeviceService == null) {
      return true;
    }
    try {
      final result = await _channel
          .invokeMethod<String>('printStructuredLabel', {
            'title': job.title,
            'lines': job.lines,
            'barcodeValue': job.barcodeValue,
            'copies': job.copies,
          });
      _deviceStatus.value = result ?? 'Print sent';
      return true;
    } on PlatformException catch (error) {
      _deviceStatus.value = error.message ?? 'Print failed';
      return false;
    } catch (error) {
      _deviceStatus.value = error.toString();
      return false;
    }
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
        'Type: ${request['mother_coil_product_name'] ?? '-'}',
        'Weight: ${request['gross_weight'] ?? request['weight'] ?? '-'} kg',
        'Alloy ID: ${request['metal_alloy_id'] ?? '-'}',
      ],
    );
  }
}
