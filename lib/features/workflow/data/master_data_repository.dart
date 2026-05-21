import '../../../core/models/available_mother_coil_item.dart';
import '../../../core/models/master_option.dart';
import '../../../core/models/production_line_catalog_item.dart';
import '../../../core/models/product_catalog_item.dart';
import '../../../core/models/raw_material_catalog_item.dart';
import '../../../core/models/truck_receipt_reference.dart';
import '../../../core/models/app_exception.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/app_config_service.dart';

class MasterDataRepository {
  MasterDataRepository({
    required ApiClient apiClient,
    required AppConfigService appConfigService,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MasterOption>> fetchMotherCoilProducts() =>
      _fetchOptions('/masters/mother-coil-products');

  Future<List<ProductCatalogItem>> fetchBabyCoilProducts() async {
    final raw = await _fetchList('/masters/baby-coil-products');
    return raw
        .map(ProductCatalogItem.fromJson)
        .where((item) => item.id > 0 && item.name.trim().isNotEmpty)
        .toList();
  }

  Future<List<AvailableMotherCoilItem>> fetchAvailableMotherCoils() async {
    final raw = await _fetchList('/masters/mother-coils-available');
    return raw
        .map(AvailableMotherCoilItem.fromJson)
        .where((item) => item.id > 0 && item.coilNo.trim().isNotEmpty)
        .toList();
  }

  Future<List<MasterOption>> fetchStaff() => _fetchOptions('/masters/staff');

  Future<List<MasterOption>> fetchSuppliers() =>
      _fetchOptions('/masters/suppliers');

  Future<List<MasterOption>> fetchRawMaterials() =>
      _fetchOptions('/masters/raw-materials');

  Future<List<RawMaterialCatalogItem>> fetchRawMaterialCatalog() async {
    final raw = await _fetchList('/masters/raw-materials');
    return raw
        .map(RawMaterialCatalogItem.fromJson)
        .where(
          (item) =>
              item.rawMaterialId > 0 && item.rawMaterialName.trim().isNotEmpty,
        )
        .toList();
  }

  Future<List<TruckReceiptReference>> fetchTruckReceiptReferences() async {
    const candidatePaths = [
      '/masters/raw-material-inward-references',
      '/masters/inward-receipts',
      '/masters/receipts',
      '/workflow/raw-material-inward-references',
    ];

    AppException? lastError;
    for (final path in candidatePaths) {
      try {
        final raw = await _fetchList(path);
        return raw
            .map(TruckReceiptReference.fromJson)
            .where((item) => item.receiptNumber.trim().isNotEmpty)
            .toList();
      } on AppException catch (error) {
        lastError = error;
        if (error.statusCode == 404) {
          continue;
        }
        rethrow;
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    return const [];
  }

  Future<List<MasterOption>> fetchProductionLines() =>
      _fetchOptions('/masters/production-lines');

  Future<List<ProductionLineCatalogItem>> fetchProductionLineCatalog() async {
    final raw = await _fetchList('/masters/production-lines');
    return raw
        .map(ProductionLineCatalogItem.fromJson)
        .where((item) => item.id > 0 && item.name.trim().isNotEmpty)
        .toList();
  }

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
