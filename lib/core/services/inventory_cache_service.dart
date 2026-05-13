import 'package:get/get.dart';

import '../models/inventory_bucket_balance.dart';

class InventoryCacheService extends GetxService {
  final balances = <InventoryBucketBalance>[].obs;
  final recentTransactions = <Map<String, dynamic>>[].obs;

  void update({
    required List<InventoryBucketBalance> summaryData,
    required List<Map<String, dynamic>> transactions,
  }) {
    balances.assignAll(summaryData);
    recentTransactions.assignAll(transactions);
  }
}
