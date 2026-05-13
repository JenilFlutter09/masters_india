class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String? message;
  final T data;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) parser,
  ) {
    return ApiEnvelope(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: parser(json['data']),
    );
  }
}
