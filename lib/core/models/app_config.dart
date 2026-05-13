class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.loginPath,
    required this.environmentLabel,
    required this.connectTimeoutSeconds,
    required this.receiveTimeoutSeconds,
  });

  final String baseUrl;
  final String loginPath;
  final String environmentLabel;
  final int connectTimeoutSeconds;
  final int receiveTimeoutSeconds;

  AppConfig copyWith({
    String? baseUrl,
    String? loginPath,
    String? environmentLabel,
    int? connectTimeoutSeconds,
    int? receiveTimeoutSeconds,
  }) {
    return AppConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      loginPath: loginPath ?? this.loginPath,
      environmentLabel: environmentLabel ?? this.environmentLabel,
      connectTimeoutSeconds:
          connectTimeoutSeconds ?? this.connectTimeoutSeconds,
      receiveTimeoutSeconds:
          receiveTimeoutSeconds ?? this.receiveTimeoutSeconds,
    );
  }
}
