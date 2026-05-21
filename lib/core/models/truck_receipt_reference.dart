class TruckReceiptReference {
  const TruckReceiptReference({
    required this.receiptNumber,
    this.invoiceNumber,
    this.truckNumber,
    this.customerId,
    this.customerName,
    this.rawMaterialName,
    this.rawMaterialVariant,
  });

  final String receiptNumber;
  final String? invoiceNumber;
  final String? truckNumber;
  final int? customerId;
  final String? customerName;
  final String? rawMaterialName;
  final String? rawMaterialVariant;

  factory TruckReceiptReference.fromJson(Map<String, dynamic> json) {
    return TruckReceiptReference(
      receiptNumber: _readString(json, const [
        'receipt_no',
        'receipt_number',
        'inward_receipt_no',
        'receipt',
      ]),
      invoiceNumber: _readOptionalString(json, const [
        'invoice_no',
        'invoice_number',
        'inward_invoice_no',
        'invoice',
      ]),
      truckNumber: _readOptionalString(json, const [
        'truck_no',
        'truck_number',
        'vehicle_no',
        'vehicle_number',
      ]),
      customerId: _readOptionalInt(json, const ['customer_id']),
      customerName: _readOptionalString(json, const ['customer_name']),
      rawMaterialName: _readOptionalString(json, const [
        'raw_material_name',
        'material_name',
        'name',
      ]),
      rawMaterialVariant: _readOptionalString(json, const [
        'raw_material_variant',
        'raw_material_type',
        'material_type',
        'type',
      ]),
    );
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

  static int? _readOptionalInt(Map<String, dynamic> json, List<String> keys) {
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
    return null;
  }
}
