class MasterOption {
  const MasterOption({required this.id, required this.name});

  final int id;
  final String name;

  factory MasterOption.fromJson(Map<String, dynamic> json) {
    return MasterOption(id: _readId(json), name: _readName(json));
  }

  static int _readId(Map<String, dynamic> json) {
    const preferredKeys = [
      'id',
      'value',
      'raw_material_id',
      'supplier_id',
      'customer_id',
      'production_line_id',
      'metal_alloy_id',
      'weighbridge_id',
      'dross_id',
      'product_id',
      'staff_id',
    ];

    for (final key in preferredKeys) {
      final value = json[key];
      final parsed = _parseInt(value);
      if (parsed != null) {
        return parsed;
      }
    }

    for (final entry in json.entries) {
      final key = entry.key.toLowerCase();
      if (key == 'id' || key.endsWith('_id')) {
        final parsed = _parseInt(entry.value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  static String _readName(Map<String, dynamic> json) {
    const preferredKeys = [
      'name',
      'label',
      'title',
      'raw_material_name',
      'supplier_name',
      'customer_name',
      'production_line_name',
      'metal_alloy_name',
      'weighbridge_name',
      'product_name',
      'staff_name',
      'type',
    ];

    for (final key in preferredKeys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    for (final entry in json.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value?.toString().trim();
      if ((key == 'name' || key.endsWith('_name')) &&
          value != null &&
          value.isNotEmpty) {
        return value;
      }
    }

    return '';
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
