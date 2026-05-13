import '../../../core/services/api_client.dart';
import '../../../core/services/app_config_service.dart';

class WorkflowRepository {
  WorkflowRepository({
    required ApiClient apiClient,
    required AppConfigService appConfigService,
  }) : _apiClient = apiClient,
       _appConfigService = appConfigService;

  final ApiClient _apiClient;
  final AppConfigService _appConfigService;

  AppConfigService get configService => _appConfigService;

  Future<Map<String, dynamic>> rawMaterialInward(
    Map<String, dynamic> payload,
  ) => _postWorkflow('/workflow/raw-material-inward', payload);

  Future<Map<String, dynamic>> weighbridgeOutbound(
    Map<String, dynamic> payload,
  ) => _postWorkflow('/workflow/weighbridge-outbound', payload);

  Future<Map<String, dynamic>> scrapToFurnace(Map<String, dynamic> payload) =>
      _postWorkflow('/workflow/scrap-to-furnace', payload);

  Future<Map<String, dynamic>> furnaceOutput(Map<String, dynamic> payload) =>
      _postWorkflow('/workflow/furnace-output', payload);

  Future<Map<String, dynamic>> dispatchMotherCoil(
    Map<String, dynamic> payload,
  ) => _postWorkflow('/workflow/dispatch/mother-coil', payload);

  Future<Map<String, dynamic>> babyInward(Map<String, dynamic> payload) =>
      _postWorkflow('/workflow/baby-inward', payload);

  Future<Map<String, dynamic>> dispatchBabyProduct(
    Map<String, dynamic> payload,
  ) => _postWorkflow('/workflow/dispatch/baby-product', payload);

  Future<Map<String, dynamic>> scrapGeneration(Map<String, dynamic> payload) =>
      _postWorkflow('/workflow/scrap-generation', payload);

  Future<Map<String, dynamic>> drossInward(Map<String, dynamic> payload) =>
      _postWorkflow('/workflow/dross-inward', payload);

  Future<Map<String, dynamic>> drossOutward(Map<String, dynamic> payload) =>
      _postWorkflow('/workflow/dross-outward', payload);

  Future<Map<String, dynamic>> _postWorkflow(
    String path,
    Map<String, dynamic> payload,
  ) => _apiClient.post(path, body: payload);
}
