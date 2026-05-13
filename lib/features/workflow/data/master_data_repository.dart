import '../../../core/models/master_option.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/app_config_service.dart';

class MasterDataRepository {
  MasterDataRepository({
    required ApiClient apiClient,
    required AppConfigService appConfigService,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MasterOption>> fetchProducts() =>
      _fetchOptions('/masters/products');

  Future<List<MasterOption>> fetchStaff() => _fetchOptions('/masters/staff');

  Future<List<MasterOption>> fetchSuppliers() =>
      _fetchOptions('/masters/suppliers');

  Future<List<MasterOption>> fetchRawMaterials() =>
      _fetchOptions('/masters/raw-materials');

  Future<List<MasterOption>> fetchProductionLines() =>
      _fetchOptions('/masters/production-lines');

  Future<List<MasterOption>> fetchMetalAlloys() =>
      _fetchOptions('/masters/metal-alloys');

  Future<List<MasterOption>> fetchCustomers() =>
      _fetchOptions('/masters/customers');

  Future<List<MasterOption>> fetchWeighbridges() =>
      _fetchOptions('/masters/weighbridges');

  Future<List<MasterOption>> fetchDrossOptions() =>
      _fetchOptions('/masters/dross');

  Future<List<String>> fetchDrossTypes() async {
    final raw = await _fetchList('/masters/dross');
    final types =
        raw
            .map((item) => item['type']?.toString() ?? '')
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return types;
  }

  Future<List<MasterOption>> _fetchOptions(String path) async {
    final raw = await _fetchList(path);
    return raw
        .map(MasterOption.fromJson)
        .where((item) => item.id > 0 && item.name.trim().isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    final response = await _apiClient.get(path);
    final raw = response['data'] as List<dynamic>? ?? const [];
    return raw
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }
}
