import 'package:get/get.dart';

import '../models/app_config.dart';
import 'storage_service.dart';

class AppConfigService extends GetxService {
  AppConfigService(this._storageService)
    : config = AppConfig(
        baseUrl: _storageService.baseUrl,
        loginPath: _storageService.loginPath,
        environmentLabel: 'production-floor',
        connectTimeoutSeconds: 20,
        receiveTimeoutSeconds: 30,
      ).obs;

  final StorageService _storageService;
  final Rx<AppConfig> config;

  Future<void> updateBaseUrl(String value) async {
    await _storageService.saveBaseUrl(value);
    config.value = config.value.copyWith(baseUrl: value);
  }

  Future<void> updateLoginPath(String value) async {
    await _storageService.saveLoginPath(value);
    config.value = config.value.copyWith(loginPath: value);
  }
}
