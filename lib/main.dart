import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'app/app_routes.dart';
import 'core/services/api_client.dart';
import 'core/services/app_config_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/bluetooth_device_service.dart';
import 'core/services/device_reconnect_service.dart';
import 'core/services/inventory_cache_service.dart';
import 'core/services/printer_service.dart';
import 'core/services/scale_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/dashboard/data/inventory_repository.dart';
import 'features/workflow/data/master_data_repository.dart';
import 'features/workflow/data/workflow_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final deviceServices = await _initializeServices();
  unawaited(_initializeDeviceServices(deviceServices));
  runApp(
    MastersIndiaApp(
      initialRoute: Get.find<AuthService>().isLoggedIn.value
          ? AppRoutes.dashboard
          : AppRoutes.login,
    ),
  );
}

typedef _DeviceServices =
    ({
      BluetoothDeviceService bluetoothDeviceService,
      PrinterService printerService,
    });

Future<void> _initializeDeviceServices(
  ({
    BluetoothDeviceService bluetoothDeviceService,
    PrinterService printerService,
  })
  services,
) async {
  try {
    await services.bluetoothDeviceService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Bluetooth device service initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await services.printerService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Printer service initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<_DeviceServices> _initializeServices() async {
  final storageService = Get.put(StorageService(), permanent: true);
  final appConfigService = Get.put(
    AppConfigService(storageService),
    permanent: true,
  );
  final apiClient = Get.put(
    ApiClient(
      appConfigService: appConfigService,
      storageService: storageService,
    ),
    permanent: true,
  );
  final authRepository = Get.put(
    AuthRepository(apiClient: apiClient, appConfigService: appConfigService),
    permanent: true,
  );
  final authService = Get.put(
    AuthService(storageService: storageService, authRepository: authRepository),
    permanent: true,
  );
  final bluetoothDeviceService = Get.put(
    BluetoothDeviceService(storageService),
    permanent: true,
  );
  Get.put(ScaleService(bluetoothDeviceService), permanent: true);
  final printerService = Get.put(
    PrinterService(bluetoothDeviceService),
    permanent: true,
  );
  Get.put(
    DeviceReconnectService(
      bluetoothDeviceService: bluetoothDeviceService,
      printerService: printerService,
    ),
    permanent: true,
  );
  Get.put(InventoryCacheService(), permanent: true);
  Get.put(
    WorkflowRepository(
      apiClient: apiClient,
      appConfigService: appConfigService,
    ),
    permanent: true,
  );
  Get.put(
    InventoryRepository(
      apiClient: apiClient,
      appConfigService: appConfigService,
    ),
    permanent: true,
  );
  Get.put(
    MasterDataRepository(
      apiClient: apiClient,
      appConfigService: appConfigService,
    ),
    permanent: true,
  );

  await authService.restoreSession();
  return (
    bluetoothDeviceService: bluetoothDeviceService,
    printerService: printerService,
  );
}
