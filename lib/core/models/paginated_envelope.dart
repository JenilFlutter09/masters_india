class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}

class PaginatedEnvelope<T> {
  const PaginatedEnvelope({
    required this.success,
    required this.data,
    required this.meta,
  });

  final bool success;
  final List<T> data;
  final PaginationMeta meta;

  factory PaginatedEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parser,
  ) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => parser(item.cast<String, dynamic>()))
        .toList();
    return PaginatedEnvelope(
      success: json['success'] == true,
      data: items,
      meta: PaginationMeta.fromJson(
        (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}
