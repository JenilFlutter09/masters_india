import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'bluetooth_device_service.dart';
import 'printer_service.dart';

class DeviceReconnectService extends GetxService with WidgetsBindingObserver {
  DeviceReconnectService({
    required BluetoothDeviceService bluetoothDeviceService,
    required PrinterService printerService,
  }) : _bluetoothDeviceService = bluetoothDeviceService,
       _printerService = printerService;

  final BluetoothDeviceService _bluetoothDeviceService;
  final PrinterService _printerService;
  bool _isRecovering = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(recoverSavedConnections());
    }
  }

  Future<void> recoverSavedConnections() async {
    if (_isRecovering) {
      return;
    }
    _isRecovering = true;
    try {
      await _runReconnectSafely(_bluetoothDeviceService.handleScaleAppResumed);
      await _runReconnectSafely(
        () => _printerService.reconnectSavedPrinter(force: true),
      );
    } finally {
      _isRecovering = false;
    }
  }

  Future<void> _runReconnectSafely(Future<dynamic> Function() action) async {
    try {
      await action().timeout(const Duration(seconds: 12));
    } catch (_) {}
  }
}
