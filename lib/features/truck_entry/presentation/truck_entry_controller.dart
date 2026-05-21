import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/models/raw_material_catalog_item.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class TruckEntryController extends WorkflowFormController {
  TruckEntryController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final invoiceNoController = TextEditingController();
  final truckNumberController = TextEditingController();
  final weighedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final grossWeightController = TextEditingController();
  final tareWeightController = TextEditingController();

  final rawMaterialCatalog = <RawMaterialCatalogItem>[];
  final rawMaterialChoiceMap = <int, RawMaterialCatalogItem>{};
  final suppliers = <MasterOption>[].obs;
  final rawMaterials = <MasterOption>[].obs;
  final rawMaterialTypes = <MasterOption>[].obs;
  final weighbridges = <MasterOption>[].obs;

  final selectedSupplierId = RxnInt();
  final selectedRawMaterialChoiceId = RxnInt();
  final selectedRawMaterialId = RxnInt();
  final selectedRawMaterialTypeId = RxnInt();
  final selectedWeighbridgeId = RxnInt();

  RawMaterialCatalogItem? get selectedRawMaterialChoice {
    final choiceId = selectedRawMaterialChoiceId.value;
    if (choiceId == null) {
      return null;
    }
    return rawMaterialChoiceMap[choiceId];
  }

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final supplierOptions = await masterDataRepository.fetchSuppliers();
      final rawMaterialOptions = await masterDataRepository
          .fetchRawMaterialCatalog();
      final weighbridgeOptions = await masterDataRepository.fetchWeighbridges();
      suppliers.assignAll(supplierOptions);
      rawMaterialCatalog
        ..clear()
        ..addAll(rawMaterialOptions);
      rawMaterials.assignAll(
        _buildRawMaterialChoiceOptions(rawMaterialOptions),
      );
      weighbridges.assignAll(weighbridgeOptions);
      _syncRawMaterialTypes();
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

  String? validateRequiredWeightValue(String? value, String label) {
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

  String? validateOptionalWeightValue(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return '$label must be a valid number';
    }
    return null;
  }

  String? validateWeightValue(String? value, String label) =>
      validateRequiredWeightValue(value, label);

  void _clearInvalidSelections() {
    if (!_containsOption(suppliers, selectedSupplierId.value)) {
      selectedSupplierId.value = null;
    }
    if (!_containsOption(rawMaterials, selectedRawMaterialChoiceId.value)) {
      selectedRawMaterialChoiceId.value = null;
      selectedRawMaterialId.value = null;
      selectedRawMaterialTypeId.value = null;
    }
    if (!_containsOption(rawMaterialTypes, selectedRawMaterialTypeId.value)) {
      selectedRawMaterialTypeId.value = null;
    }
    if (!_containsOption(weighbridges, selectedWeighbridgeId.value)) {
      selectedWeighbridgeId.value = null;
    }
  }

  void onRawMaterialChanged(int? choiceId) {
    selectedRawMaterialChoiceId.value = choiceId;
    final selectedItem = choiceId == null
        ? null
        : rawMaterialChoiceMap[choiceId];
    selectedRawMaterialId.value = selectedItem?.rawMaterialId;
    selectedRawMaterialTypeId.value = selectedItem?.rawMaterialTypeId;
    _syncRawMaterialTypes();
  }

  void _syncRawMaterialTypes() {
    final rawMaterialId = selectedRawMaterialId.value;
    if (rawMaterialId == null || rawMaterialId <= 0) {
      rawMaterialTypes.clear();
      selectedRawMaterialTypeId.value = null;
      return;
    }

    final seenIds = <int>{};
    final options = rawMaterialCatalog
        .where((item) => item.rawMaterialId == rawMaterialId)
        .map((item) => item.rawMaterialTypeOption)
        .whereType<MasterOption>()
        .where((item) => seenIds.add(item.id))
        .toList();

    rawMaterialTypes.assignAll(options);
    final selectedTypeId = selectedRawMaterialTypeId.value;
    if (!_containsOption(rawMaterialTypes, selectedTypeId)) {
      selectedRawMaterialTypeId.value = null;
    } else if (selectedTypeId != null) {
      selectedRawMaterialTypeId.value = selectedTypeId;
    }
  }

  List<MasterOption> _buildRawMaterialChoiceOptions(
    List<RawMaterialCatalogItem> items,
  ) {
    rawMaterialChoiceMap.clear();
    final options = <MasterOption>[];
    for (var index = 0; index < items.length; index++) {
      final choiceId = index + 1;
      final item = items[index];
      rawMaterialChoiceMap[choiceId] = item;
      options.add(MasterOption(id: choiceId, name: item.displayLabel));
    }
    return options;
  }

  bool _containsOption(List<MasterOption> options, int? value) {
    if (value == null || value <= 0) {
      return false;
    }
    return options.any((option) => option.id == value);
  }

  @override
  Map<String, dynamic> buildPayload() {
    final selectedItem = selectedRawMaterialChoice;
    return {
      'invoice_no': invoiceNoController.text.trim(),
      'supplier_id': selectedSupplierId.value,
      'raw_material_id': selectedItem?.rawMaterialId,
      'raw_material_variant': selectedItem?.rawMaterialTypeName,
      'weighbridge_id': selectedWeighbridgeId.value,
      'gross_weight': double.parse(grossWeightController.text.trim()),
      'tare_weight': double.tryParse(tareWeightController.text.trim()) ?? 0,
      'truck_no': truckNumberController.text.trim(),
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
    final netWeight = data['net_weight']?.toString() ?? '-';
    return 'Truck entry saved. Receipt: $receipt | Invoice: $invoice | Net: $netWeight';
  }

  @override
  void disposeControllers() {
    invoiceNoController.dispose();
    truckNumberController.dispose();
    weighedAtController.dispose();
    grossWeightController.dispose();
    tareWeightController.dispose();
  }
}
