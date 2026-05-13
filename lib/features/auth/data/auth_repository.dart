import '../../../core/services/api_client.dart';
import '../../../core/services/app_config_service.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required AppConfigService appConfigService,
  }) : _apiClient = apiClient,
       _appConfigService = appConfigService;

  final ApiClient _apiClient;
  final AppConfigService _appConfigService;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _apiClient.post(
    _appConfigService.config.value.loginPath,
    body: {'email': email, 'password': password},
  );

  Future<Map<String, dynamic>> logout() =>
      _apiClient.post('/auth/logout', body: const {});

  Future<Map<String, dynamic>> me() => _apiClient.get('/auth/me');
}
