import '../../../core/models/inventory_bucket_balance.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/app_config_service.dart';

class InventorySnapshot {
  const InventorySnapshot({
    required this.balances,
    required this.recentTransactions,
  });

  final List<InventoryBucketBalance> balances;
  final List<Map<String, dynamic>> recentTransactions;
}

class InventoryRepository {
  InventoryRepository({
    required ApiClient apiClient,
    required AppConfigService appConfigService,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<InventorySnapshot> fetchInventorySummary() async {
    final response = await _apiClient.get('/workflow/inventory-summary');
    final data = response['data'] is Map
        ? (response['data'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final balances = (data['bucket_summary'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              InventoryBucketBalance.fromJson(item.cast<String, dynamic>()),
        )
        .toList();
    return InventorySnapshot(balances: balances, recentTransactions: const []);
  }
}
