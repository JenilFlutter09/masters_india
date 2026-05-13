import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/inventory_bucket_balance.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/inventory_cache_service.dart';
import '../data/inventory_repository.dart';

class DashboardController extends GetxController {
  DashboardController({
    required InventoryRepository inventoryRepository,
    required InventoryCacheService inventoryCacheService,
    required AuthService authService,
  }) : _inventoryRepository = inventoryRepository,
       _inventoryCacheService = inventoryCacheService,
       _authService = authService;

  final InventoryRepository _inventoryRepository;
  final InventoryCacheService _inventoryCacheService;
  final AuthService _authService;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  List<InventoryBucketBalance> get balances => _inventoryCacheService.balances;
  List<Map<String, dynamic>> get recentTransactions =>
      _inventoryCacheService.recentTransactions;
  String get userEmail => _authService.userEmail.value ?? 'Operator';
  String get userName => _authService.userName.value ?? 'Operator';

  @override
  void onInit() {
    super.onInit();
    if (_inventoryCacheService.balances.isEmpty) {
      refreshInventory();
    }
  }

  Future<void> refreshInventory() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final snapshot = await _inventoryRepository.fetchInventorySummary();
      _inventoryCacheService.update(
        summaryData: snapshot.balances,
        transactions: snapshot.recentTransactions,
      );
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
