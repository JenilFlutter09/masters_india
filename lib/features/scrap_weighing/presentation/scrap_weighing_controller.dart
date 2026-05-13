import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class ScrapWeighingController extends WorkflowFormController {
  ScrapWeighingController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final truckNumberController = TextEditingController();
  final weighedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final grossWeightController = TextEditingController();
  final tareWeightController = TextEditingController();

  final suppliers = <MasterOption>[].obs;
  final rawMaterials = <MasterOption>[].obs;
  final weighbridges = <MasterOption>[].obs;

  final selectedSupplierId = RxnInt();
  final selectedRawMaterialId = RxnInt();
  final selectedWeighbridgeId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final supplierOptions = await masterDataRepository.fetchSuppliers();
      final rawMaterialOptions = await masterDataRepository.fetchRawMaterials();
      final weighbridgeOptions = await masterDataRepository.fetchWeighbridges();
      suppliers.assignAll(supplierOptions);
      rawMaterials.assignAll(rawMaterialOptions);
      weighbridges.assignAll(weighbridgeOptions);
      _clearInvalidSelections();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoadingMasters.value = false;
    }
  }

  void captureGrossWeight() {
    final reading = liveReading.value;
    if (reading != null) {
      grossWeightController.text = reading.weight.toStringAsFixed(2);
    }
  }

  void captureTareWeight() {
    final reading = liveReading.value;
    if (reading != null) {
      tareWeightController.text = reading.weight.toStringAsFixed(2);
    }
  }

  String? validateText(String? value, String label) =>
      FormValidators.requiredField(value, label);

  String? validateSelection(int? value, String label) =>
      (value == null || value <= 0) ? '$label is required' : null;

  String? validateWeightValue(String? value, String label) {
    final required = FormValidators.requiredField(value, label);
    if (required != null) {
      return required;
    }
    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return '$label must be a valid number';
    }
    return null;
  }

  void _clearInvalidSelections() {
    if (!_containsOption(suppliers, selectedSupplierId.value)) {
      selectedSupplierId.value = null;
    }
    if (!_containsOption(rawMaterials, selectedRawMaterialId.value)) {
      selectedRawMaterialId.value = null;
    }
    if (!_containsOption(weighbridges, selectedWeighbridgeId.value)) {
      selectedWeighbridgeId.value = null;
    }
  }

  bool _containsOption(List<MasterOption> options, int? value) {
    if (value == null || value <= 0) {
      return false;
    }
    return options.any((option) => option.id == value);
  }

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'supplier_id': selectedSupplierId.value,
      'raw_material_id': selectedRawMaterialId.value,
      'weighbridge_id': selectedWeighbridgeId.value,
      'gross_weight': double.parse(grossWeightController.text.trim()),
      'tare_weight': double.parse(tareWeightController.text.trim()),
      'truck_no': truckNumberController.text.trim(),
      'weighed_at': weighedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) {
    return workflowRepository.rawMaterialInward(payload);
  }

  @override
  String buildSuccessMessage(Map<String, dynamic> response) {
    final data = extractResultData(response);
    final receipt = data['receipt_no']?.toString() ?? '-';
    final invoice = data['invoice_no']?.toString() ?? '-';
    return 'Scrap inward saved. Receipt: $receipt | Invoice: $invoice';
  }

  @override
  void disposeControllers() {
    truckNumberController.dispose();
    weighedAtController.dispose();
    grossWeightController.dispose();
    tareWeightController.dispose();
  }
}
