import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mastersindia/core/models/label_job.dart';
import 'package:mastersindia/core/models/inventory_bucket_balance.dart';
import 'package:mastersindia/core/services/api_client.dart';
import 'package:mastersindia/core/services/app_config_service.dart';
import 'package:mastersindia/core/services/auth_service.dart';
import 'package:mastersindia/core/services/inventory_cache_service.dart';
import 'package:mastersindia/core/services/printer_service.dart';
import 'package:mastersindia/core/services/scale_service.dart';
import 'package:mastersindia/core/services/storage_service.dart';
import 'package:mastersindia/features/auth/data/auth_repository.dart';
import 'package:mastersindia/features/dashboard/data/inventory_repository.dart';
import 'package:mastersindia/features/workflow/data/master_data_repository.dart';
import 'package:mastersindia/features/workflow/data/workflow_repository.dart';

Future<void> bootstrapTestBindings() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  Get.reset();
}

class TestContext {
  TestContext._({
    required this.storageService,
    required this.appConfigService,
    required this.apiClient,
    required this.authRepository,
    required this.authService,
    required this.scaleService,
    required this.printerService,
    required this.workflowRepository,
    required this.masterDataRepository,
    required this.inventoryCacheService,
  });

  final StorageService storageService;
  final AppConfigService appConfigService;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AuthService authService;
  final ScaleService scaleService;
  final PrinterService printerService;
  final WorkflowRepository workflowRepository;
  final MasterDataRepository masterDataRepository;
  final InventoryCacheService inventoryCacheService;
}

Future<TestContext> createTestContext({http.Client? client}) async {
  final storageService = StorageService.memory();
  await storageService.clearSession();
  final appConfigService = AppConfigService(storageService);
  final apiClient = ApiClient(
    appConfigService: appConfigService,
    storageService: storageService,
    httpClient: client ?? MockClient((_) async => http.Response('{}', 200)),
  );
  final authRepository = TestAuthRepository(
    apiClient: apiClient,
    appConfigService: appConfigService,
  );
  final authService = AuthService(
    storageService: storageService,
    authRepository: authRepository,
  );
  final scaleService = ScaleService.test(
    mockStatus: 'Disconnected',
    mockConfigured: false,
    mockConnected: false,
  );
  final printerService = PrinterService.test(
    mockStatus: 'Disconnected',
    mockConfigured: false,
    mockConnected: false,
  );
  final workflowRepository = WorkflowRepository(
    apiClient: apiClient,
    appConfigService: appConfigService,
  );
  final masterDataRepository = MasterDataRepository(
    apiClient: apiClient,
    appConfigService: appConfigService,
  );
  final inventoryCacheService = InventoryCacheService();

  return TestContext._(
    storageService: storageService,
    appConfigService: appConfigService,
    apiClient: apiClient,
    authRepository: authRepository,
    authService: authService,
    scaleService: scaleService,
    printerService: printerService,
    workflowRepository: workflowRepository,
    masterDataRepository: masterDataRepository,
    inventoryCacheService: inventoryCacheService,
  );
}

class TestAuthRepository extends AuthRepository {
  TestAuthRepository({
    required super.apiClient,
    required super.appConfigService,
  });

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return {
      'success': true,
      'data': {
        'user': {'id': 1, 'name': 'Admin User', 'email': email},
        'token': 'token-for-$email',
      },
    };
  }
}

class FakeInventoryRepository extends InventoryRepository {
  FakeInventoryRepository({
    required super.apiClient,
    required super.appConfigService,
  });

  @override
  Future<InventorySnapshot> fetchInventorySummary() async {
    return const InventorySnapshot(
      balances: [
        InventoryBucketBalance(bucket: 'scrap', balance: '1200'),
        InventoryBucketBalance(bucket: 'furnace_wip', balance: '540'),
        InventoryBucketBalance(bucket: 'mother_coil', balance: '24'),
        InventoryBucketBalance(bucket: 'dross', balance: '88'),
      ],
      recentTransactions: [
        {'title': 'Truck Entry', 'message': 'Receipt RC-1001 created'},
      ],
    );
  }
}

class RecordingPrinterService extends PrinterService {
  RecordingPrinterService()
    : super.test(mockConfigured: true, mockConnected: true);

  LabelJob? lastJob;

  @override
  Future<bool> printLabel(LabelJob job) async {
    lastJob = job;
    return true;
  }
}
