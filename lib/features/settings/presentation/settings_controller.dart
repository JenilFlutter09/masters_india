import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/label_job.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/bluetooth_device_service.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/services/scale_service.dart';

class SettingsController extends GetxController {
  SettingsController({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;
  final baseUrlController = TextEditingController();
  final loginPathController = TextEditingController();
  final isSaving = false.obs;
  final feedback = RxnString();

  AppConfigService get _configService => Get.find<AppConfigService>();
  BluetoothDeviceService get _bluetoothService =>
      Get.find<BluetoothDeviceService>();
  ScaleService get scaleService => Get.find<ScaleService>();
  PrinterService get printerService => Get.find<PrinterService>();

  BluetoothEndpoint get scaleEndpoint =>
      _bluetoothService.endpoint(DeviceRole.scale);
  BluetoothEndpoint get printerEndpoint =>
      _bluetoothService.endpoint(DeviceRole.printer);

  @override
  void onInit() {
    super.onInit();
    baseUrlController.text = _configService.config.value.baseUrl;
    loginPathController.text = _configService.config.value.loginPath;
  }

  Future<void> saveConfig() async {
    isSaving.value = true;
    feedback.value = null;
    await _configService.updateBaseUrl(baseUrlController.text.trim());
    await _configService.updateLoginPath(loginPathController.text.trim());
    feedback.value = 'Configuration saved.';
    isSaving.value = false;
  }

  Future<void> refreshDevices() async {
    await scaleEndpoint.loadPairedDevices();
    await printerEndpoint.loadPairedDevices();
    feedback.value = 'Device list refreshed.';
  }

  Future<void> connectScale(BluetoothDevice device) async {
    await scaleEndpoint.connect(device);
    feedback.value = 'Scale connected to ${device.name}.';
  }

  Future<void> disconnectScale() async {
    final success = await scaleEndpoint.disconnect();
    feedback.value = success
        ? 'Scale disconnected.'
        : 'Failed to disconnect scale.';
  }

  Future<void> connectPrinter(BluetoothDevice device) async {
    final success = await printerService.connectPrinter(device);
    feedback.value = success
        ? 'Printer connected to ${device.name}.'
        : 'Failed to connect printer to ${device.name}.';
  }

  Future<void> disconnectPrinter() async {
    final success = await printerService.disconnectPrinter();
    feedback.value = success
        ? 'Printer disconnected.'
        : 'Failed to disconnect printer.';
  }

  Future<void> testPrint() async {
    final success = await printerService.printLabel(
      const LabelJob(
        title: 'Printer Test',
        lines: ['MastersIndia', 'Bluetooth printer test'],
        barcodeValue: 'TEST123',
      ),
    );
    feedback.value = success ? 'Test print sent.' : 'Printer test failed.';
  }

  void testScaleRead() {
    final reading = scaleService.currentReading.value;
    feedback.value = reading == null
        ? 'No live scale reading available right now.'
        : 'Latest scale value: ${reading.weight.toStringAsFixed(2)} ${reading.unit}';
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onReady() {
    super.onReady();
    printerService.refreshStatus(showDisconnectedFeedback: false);
  }

  @override
  void onClose() {
    baseUrlController.dispose();
    loginPathController.dispose();
    super.onClose();
  }
}
