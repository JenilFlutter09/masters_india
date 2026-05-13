import 'dart:async';

import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'storage_service.dart';

enum DeviceRole { scale, printer }

extension DeviceRoleX on DeviceRole {
  String get label => this == DeviceRole.scale ? 'Scale' : 'Printer';
}

class BluetoothEndpoint {
  BluetoothEndpoint({required this.role, required this.storageService})
    : bluetooth = FlutterBluetoothClassic();

  final DeviceRole role;
  final StorageService storageService;
  final FlutterBluetoothClassic bluetooth;
  final pairedDevices = <BluetoothDevice>[].obs;
  final isBluetoothEnabled = false.obs;
  final isConnected = false.obs;
  final connectedDevice = Rxn<BluetoothDevice>();
  final status = 'Not connected'.obs;
  final _dataController = StreamController<BluetoothData>.broadcast();

  Stream<BluetoothData> get dataStream => _dataController.stream;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<BluetoothState>? _stateSubscription;
  StreamSubscription<BluetoothData>? _dataSubscription;

  String? get selectedAddress => role == DeviceRole.scale
      ? storageService.scaleAddress
      : storageService.printerAddress;

  String? get selectedName => role == DeviceRole.scale
      ? storageService.scaleName
      : storageService.printerName;

  Future<void> initialize() async {
    await _ensurePermissions();
    isBluetoothEnabled.value = await bluetooth.isBluetoothEnabled();
    await loadPairedDevices();
    _stateSubscription = bluetooth.onStateChanged.listen((state) {
      isBluetoothEnabled.value = state.isEnabled;
    });
    _connectionSubscription = bluetooth.onConnectionChanged.listen((state) {
      isConnected.value = state.isConnected;
      status.value = state.status;
      if (!state.isConnected) {
        connectedDevice.value = null;
      }
    });
    _dataSubscription = bluetooth.onDataReceived.listen(_dataController.add);
    await reconnectSaved();
  }

  Future<void> _ensurePermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> loadPairedDevices() async {
    pairedDevices.assignAll(await bluetooth.getPairedDevices());
  }

  Future<void> saveSelection(BluetoothDevice device) async {
    if (role == DeviceRole.scale) {
      await storageService.saveScaleSelection(
        address: device.address,
        name: device.name,
      );
    } else {
      await storageService.savePrinterSelection(
        address: device.address,
        name: device.name,
      );
    }
  }

  Future<void> reconnectSaved() async {
    final address = selectedAddress;
    if (address == null || address.isEmpty) {
      return;
    }
    final device = pairedDevices.firstWhereOrNull(
      (item) => item.address == address,
    );
    if (device != null) {
      await connect(device, persistSelection: false);
    }
  }

  Future<bool> connect(
    BluetoothDevice device, {
    bool persistSelection = true,
  }) async {
    final result = await bluetooth.connect(device.address);
    if (result) {
      connectedDevice.value = device;
      status.value = 'Connected to ${device.name}';
      if (persistSelection) {
        await saveSelection(device);
      }
    }
    return result;
  }

  Future<bool> disconnect() async {
    final result = await bluetooth.disconnect();
    if (result) {
      connectedDevice.value = null;
      status.value = 'Disconnected';
    }
    return result;
  }

  Future<bool> sendString(String message) => bluetooth.sendString(message);

  void dispose() {
    _connectionSubscription?.cancel();
    _stateSubscription?.cancel();
    _dataSubscription?.cancel();
    _dataController.close();
  }
}

class BluetoothDeviceService extends GetxService {
  BluetoothDeviceService(StorageService storageService)
    : _endpoints = {
        DeviceRole.scale: BluetoothEndpoint(
          role: DeviceRole.scale,
          storageService: storageService,
        ),
        DeviceRole.printer: BluetoothEndpoint(
          role: DeviceRole.printer,
          storageService: storageService,
        ),
      };
  final Map<DeviceRole, BluetoothEndpoint> _endpoints;

  BluetoothEndpoint endpoint(DeviceRole role) => _endpoints[role]!;

  Stream<BluetoothData> dataStream(DeviceRole role) =>
      endpoint(role).dataStream;

  Future<void> initialize() async {
    for (final endpoint in _endpoints.values) {
      await endpoint.initialize();
    }
  }
}
