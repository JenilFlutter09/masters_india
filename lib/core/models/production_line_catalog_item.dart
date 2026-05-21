import 'master_option.dart';

class ProductionLineCatalogItem {
  const ProductionLineCatalogItem({
    required this.id,
    required this.name,
    this.productName,
    this.drossType,
  });

  final int id;
  final String name;
  final String? productName;
  final String? drossType;

  MasterOption get option => MasterOption(id: id, name: name);

  factory ProductionLineCatalogItem.fromJson(Map<String, dynamic> json) {
    return ProductionLineCatalogItem(
      id: _readInt(json, const ['id', 'production_line_id', 'value']),
      name: _readString(json, const ['name', 'production_line_name', 'label']),
      productName: _readOptionalString(json, const ['product', 'product_name']),
      drossType: _readOptionalString(json, const ['dross_type', 'type']),
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

  static String? _readOptionalString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
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
