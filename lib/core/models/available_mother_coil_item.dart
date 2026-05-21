import 'master_option.dart';

class AvailableMotherCoilItem {
  const AvailableMotherCoilItem({
    required this.id,
    required this.coilNo,
    this.barcode,
    this.productName,
    this.totalWeight,
    this.convertedWeight,
    this.remainingWeight,
  });

  final int id;
  final String coilNo;
  final String? barcode;
  final String? productName;
  final double? totalWeight;
  final double? convertedWeight;
  final double? remainingWeight;

  String get displayLabel {
    final product = (productName ?? '').trim();
    final remaining = remainingWeight;
    final details = <String>[
      coilNo,
      if (product.isNotEmpty) product,
      if (remaining != null) 'Remaining ${remaining.toStringAsFixed(2)} kg',
    ];
    return details.join(' • ');
  }

  MasterOption get option => MasterOption(id: id, name: displayLabel);

  factory AvailableMotherCoilItem.fromJson(Map<String, dynamic> json) {
    return AvailableMotherCoilItem(
      id: _readInt(json, const ['id', 'mother_coil_id', 'value']),
      coilNo: _readString(json, const ['coil_no', 'mother_coil_no', 'name']),
      barcode: _readOptionalString(json, const [
        'barcode',
        'mother_coil_barcode',
      ]),
      productName: _readOptionalString(json, const [
        'product_name',
        'mother_product_name',
      ]),
      totalWeight: _readOptionalDouble(json, const ['total_weight']),
      convertedWeight: _readOptionalDouble(json, const ['converted_weight']),
      remainingWeight: _readOptionalDouble(json, const [
        'remaining_weight',
        'balance',
      ]),
    );
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
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

  static double? _readOptionalDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}
