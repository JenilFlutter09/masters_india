import 'master_option.dart';

class RawMaterialCatalogItem {
  const RawMaterialCatalogItem({
    required this.rawMaterialId,
    required this.rawMaterialName,
    this.rawMaterialTypeId,
    this.rawMaterialTypeName,
  });

  final int rawMaterialId;
  final String rawMaterialName;
  final int? rawMaterialTypeId;
  final String? rawMaterialTypeName;

  String get displayLabel {
    final typeName = rawMaterialTypeName?.trim() ?? '';
    if (typeName.isEmpty) {
      return rawMaterialName;
    }
    return '$rawMaterialName • $typeName';
  }

  MasterOption get rawMaterialOption =>
      MasterOption(id: rawMaterialId, name: rawMaterialName);

  MasterOption? get rawMaterialTypeOption {
    final typeId = rawMaterialTypeId;
    final typeName = rawMaterialTypeName?.trim() ?? '';
    if (typeId == null || typeId <= 0 || typeName.isEmpty) {
      return null;
    }
    return MasterOption(id: typeId, name: typeName);
  }

  factory RawMaterialCatalogItem.fromJson(Map<String, dynamic> json) {
    return RawMaterialCatalogItem(
      rawMaterialId: _readInt(json, const [
        'raw_material_id',
        'material_id',
        'id',
        'value',
      ]),
      rawMaterialName: _readString(json, const [
        'raw_material_name',
        'material_name',
        'name',
        'label',
        'title',
      ]),
      rawMaterialTypeId: _readOptionalInt(json, const [
        'raw_material_type_id',
        'material_type_id',
        'type_id',
      ]),
      rawMaterialTypeName: _readOptionalString(json, const [
        'raw_material_type_name',
        'raw_material_type',
        'material_type_name',
        'material_type',
        'type',
      ]),
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

  static int? _readOptionalInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final parsed = _parseInt(json[key]);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
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
