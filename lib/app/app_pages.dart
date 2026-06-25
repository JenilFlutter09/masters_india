import 'package:get/get.dart';

import '../core/services/auth_service.dart';
import '../core/services/inventory_cache_service.dart';
import '../core/services/printer_service.dart';
import '../core/services/scale_service.dart';
import '../features/auth/presentation/login_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/data/inventory_repository.dart';
import '../features/dashboard/presentation/dashboard_controller.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dispatch/presentation/baby_inward_controller.dart';
import '../features/dispatch/presentation/baby_inward_screen.dart';
import '../features/dispatch/presentation/dispatch_controller.dart';
import '../features/dispatch/presentation/dispatch_screen.dart';
import '../features/dross_weighing/presentation/dross_weighing_controller.dart';
import '../features/dross_weighing/presentation/dross_weighing_screen.dart';
import '../features/line_output/presentation/line_output_controller.dart';
import '../features/line_output/presentation/line_output_screen.dart';
import '../features/scrap_weighing/presentation/scrap_weighing_controller.dart';
import '../features/scrap_weighing/presentation/scrap_weighing_screen.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/truck_entry/presentation/truck_entry_controller.dart';
import '../features/truck_entry/presentation/truck_entry_screen.dart';
import '../features/truck_exit/presentation/truck_exit_controller.dart';
import '../features/truck_exit/presentation/truck_exit_screen.dart';
import '../features/workflow/data/workflow_repository.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: LoginScreen.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => LoginController(authService: Get.find<AuthService>()),
          fenix: false,
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: DashboardScreen.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => DashboardController(
            inventoryRepository: Get.find<InventoryRepository>(),
            inventoryCacheService: Get.find<InventoryCacheService>(),
            authService: Get.find<AuthService>(),
          ),
          fenix: false,
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.truckEntry,
      page: TruckEntryScreen.new,
      binding: _workflowBinding(
        () => TruckEntryController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.truckExit,
      page: TruckExitScreen.new,
      binding: _workflowBinding(
        () => TruckExitController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.scrapWeighing,
      page: ScrapWeighingScreen.new,
      binding: _workflowBinding(
        () => ScrapWeighingController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.drossWeighing,
      page: DrossWeighingScreen.new,
      binding: _workflowBinding(
        () => DrossWeighingController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.lineOutput,
      page: LineOutputScreen.new,
      binding: _workflowBinding(
        () => LineOutputController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.dispatch,
      page: DispatchScreen.new,
      binding: _workflowBinding(
        () => DispatchController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.motherCoilDispatch,
      page: DispatchScreen.new,
      binding: _workflowBinding(
        () => DispatchController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.babyInward,
      page: BabyInwardScreen.new,
      binding: _workflowBinding(
        () => BabyInwardController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.babyProductDispatch,
      page: DispatchScreen.new,
      binding: _workflowBinding(
        () => DispatchController(
          workflowRepository: Get.find<WorkflowRepository>(),
          scaleService: Get.find<ScaleService>(),
          printerService: Get.find<PrinterService>(),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsScreen.new,
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => SettingsController(authService: Get.find<AuthService>()),
          fenix: false,
        ),
      ),
    ),
  ];

  static Bindings _workflowBinding<T>(T Function() factory) {
    return BindingsBuilder(() {
      Get.lazyPut<T>(factory, fenix: false);
    });
  }
}
