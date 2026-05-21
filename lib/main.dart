import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'app/app_routes.dart';
import 'core/services/api_client.dart';
import 'core/services/app_config_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/bluetooth_device_service.dart';
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
  await _initializeServices();
  runApp(
    MastersIndiaApp(
      initialRoute: Get.find<AuthService>().isLoggedIn.value
          ? AppRoutes.dashboard
          : AppRoutes.login,
    ),
  );
}

Future<void> _initializeServices() async {
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
  await bluetoothDeviceService.initialize();
  await printerService.initialize();
}
