class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  final String token;
  final int userId;
  final String name;
  final String email;

  factory AuthSession.fromLoginResponse(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AuthSession(
      token: data['token']?.toString() ?? '',
      userId: (user['id'] as num?)?.toInt() ?? 0,
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
    );
  }
}
