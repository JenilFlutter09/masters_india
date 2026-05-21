import 'master_option.dart';

class ProductCatalogItem {
  const ProductCatalogItem({
    required this.id,
    required this.name,
    required this.parameters,
  });

  final int id;
  final String name;
  final List<String> parameters;

  MasterOption get option => MasterOption(id: id, name: name);

  factory ProductCatalogItem.fromJson(Map<String, dynamic> json) {
    return ProductCatalogItem(
      id: _readInt(json, const ['id', 'product_id', 'value']),
      name: _readString(json, const ['name', 'product_name', 'label']),
      parameters: _readParameters(json['parameters']),
    );
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final parsed = _parseInt(json[key]);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static List<String> _readParameters(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static int? _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}
