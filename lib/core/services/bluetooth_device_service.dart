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
  StreamSubscription<BluetoothDevice>? _discoverySubscription;
  final Map<String, BluetoothDevice> _discoveredDeviceMap = {};
  Completer<void>? _firstPacketCompleter;
  BluetoothDevice? _pendingDevice;
  bool _listenersInitialized = false;
  bool _isConnecting = false;
  bool _isReconnecting = false;

  String? get selectedAddress => role == DeviceRole.scale
      ? storageService.scaleAddress
      : storageService.printerAddress;

  String? get selectedName => role == DeviceRole.scale
      ? storageService.scaleName
      : storageService.printerName;

  bool get supportsClassicConnection => role == DeviceRole.scale;

  Future<void> initialize() async {
    await _prepareBluetooth();
    await loadPairedDevices();
    if (_listenersInitialized) {
      if (supportsClassicConnection) {
        await reconnectSaved();
      }
      return;
    }

    isBluetoothEnabled.value = await bluetooth.isBluetoothEnabled();
    _stateSubscription = bluetooth.onStateChanged.listen((state) {
      isBluetoothEnabled.value = state.isEnabled;
      if (state.isEnabled) {
        unawaited(loadPairedDevices());
      }
    });

    _connectionSubscription = bluetooth.onConnectionChanged.listen((state) {
      if (state.isConnected) {
        status.value = state.status;
        connectedDevice.value = pairedDevices.firstWhereOrNull(
          (item) => item.address == state.deviceAddress,
        );
      } else {
        isConnected.value = false;
        connectedDevice.value = null;
        status.value = state.status;
        if (_firstPacketCompleter?.isCompleted == false) {
          _firstPacketCompleter?.completeError(
            Exception('Scale disconnected before data was received.'),
          );
        }
        _pendingDevice = null;
      }
    });

    _dataSubscription = bluetooth.onDataReceived.listen((data) {
      _dataController.add(data);
      if (!supportsClassicConnection) {
        return;
      }

      final pending = _pendingDevice;
      if (pending != null) {
        isConnected.value = true;
        connectedDevice.value = pending;
        status.value = 'Connected to ${pending.name}';
        _pendingDevice = null;
        if (_firstPacketCompleter?.isCompleted == false) {
          _firstPacketCompleter?.complete();
        }
        _firstPacketCompleter = null;
      } else if (connectedDevice.value != null) {
        isConnected.value = true;
      }
    });

    _listenersInitialized = true;
    if (supportsClassicConnection) {
      await reconnectSaved();
    }
  }

  Future<void> _ensurePermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _prepareBluetooth() async {
    await _ensurePermissions();
    final supported = await bluetooth.isBluetoothSupported();
    if (!supported) {
      throw Exception('Bluetooth is not supported on this device.');
    }

    var enabled = await bluetooth.isBluetoothEnabled();
    if (!enabled) {
      enabled = await bluetooth.enableBluetooth();
    }
    if (!enabled) {
      throw Exception('Bluetooth is off.');
    }

    isBluetoothEnabled.value = true;
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

  Future<void> clearSelection() async {
    if (role == DeviceRole.scale) {
      await storageService.clearScaleSelection();
    } else {
      await storageService.clearPrinterSelection();
    }
  }

  Future<void> reconnectSaved({bool force = false}) async {
    if (!supportsClassicConnection || _isReconnecting) {
      return;
    }
    if (isConnected.value && !force) {
      return;
    }

    final address = selectedAddress;
    if (address == null || address.isEmpty) {
      return;
    }

    _isReconnecting = true;
    try {
      if (force) {
        await disconnect(forgetSelection: false);
      }

      await _prepareBluetooth();
      await loadPairedDevices();

      var matched = pairedDevices.firstWhereOrNull(
        (item) => item.address == address,
      );
      matched ??= await _discoverDevice(address);

      if (matched != null) {
        await connect(matched, persistSelection: false);
      }
    } finally {
      _isReconnecting = false;
    }
  }

  Future<BluetoothDevice?> _discoverDevice(String address) async {
    _discoveredDeviceMap
      ..clear()
      ..addEntries(
        pairedDevices.map((device) => MapEntry(device.address, device)),
      );

    await _discoverySubscription?.cancel();
    try {
      final discoveryStarted = await bluetooth.startDiscovery();
      if (!discoveryStarted) {
        return _discoveredDeviceMap[address];
      }

      _discoverySubscription = bluetooth.onDeviceDiscovered.listen((device) {
        _discoveredDeviceMap[device.address] = device;
      });

      final until = DateTime.now().add(const Duration(seconds: 5));
      while (DateTime.now().isBefore(until)) {
        final matched = _discoveredDeviceMap[address];
        if (matched != null) {
          return matched;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }
      return _discoveredDeviceMap[address];
    } catch (_) {
      return _discoveredDeviceMap[address];
    } finally {
      try {
        await bluetooth.stopDiscovery();
      } catch (_) {}
    }
  }

  Future<void> handleAppResumed() async {
    if (!supportsClassicConnection) {
      return;
    }
    final address = selectedAddress;
    if (address == null || address.isEmpty) {
      return;
    }
    await reconnectSaved(force: true);
  }

  Future<bool> connect(
    BluetoothDevice device, {
    bool persistSelection = true,
  }) async {
    if (!supportsClassicConnection) {
      if (persistSelection) {
        await saveSelection(device);
      }
      status.value = 'Selected ${device.name}';
      return true;
    }
    if (_isConnecting) {
      return false;
    }

    _isConnecting = true;
    status.value = 'Connecting to ${device.name}...';
    try {
      await initialize();
      await _prepareBluetooth();

      try {
        await bluetooth.stopDiscovery();
      } catch (_) {}

      _pendingDevice = device;
      _firstPacketCompleter = Completer<void>();

      final connected = await bluetooth.connect(device.address);
      if (!connected) {
        throw Exception('Device rejected the connection.');
      }

      await _firstPacketCompleter!.future.timeout(const Duration(seconds: 5));
      if (persistSelection) {
        await saveSelection(device);
      }
      return true;
    } catch (_) {
      isConnected.value = false;
      connectedDevice.value = null;
      _pendingDevice = null;
      _firstPacketCompleter = null;
      await disconnect(forgetSelection: false);
      status.value = 'Unable to connect to ${device.name}';
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  Future<bool> disconnect({bool forgetSelection = false}) async {
    try {
      await bluetooth.disconnect();
    } catch (_) {}

    isConnected.value = false;
    connectedDevice.value = null;
    _pendingDevice = null;
    _firstPacketCompleter = null;
    status.value = 'Disconnected';

    if (forgetSelection) {
      await clearSelection();
    }
    return true;
  }

  Future<bool> disconnectAndForget() => disconnect(forgetSelection: true);

  Future<bool> sendString(String message) => bluetooth.sendString(message);

  void dispose() {
    _connectionSubscription?.cancel();
    _stateSubscription?.cancel();
    _dataSubscription?.cancel();
    _discoverySubscription?.cancel();
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

  Future<void> reconnectSavedScale({bool force = false}) =>
      endpoint(DeviceRole.scale).reconnectSaved(force: force);

  Future<void> handleScaleAppResumed() =>
      endpoint(DeviceRole.scale).handleAppResumed();
}
