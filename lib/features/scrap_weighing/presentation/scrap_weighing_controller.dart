import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/models/raw_material_catalog_item.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/gross_tare_net_workflow_mixin.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class ScrapWeighingController extends WorkflowFormController
    with GrossTareNetWorkflowMixin {
  ScrapWeighingController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final recordedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );

  final rawMaterialCatalog = <RawMaterialCatalogItem>[];
  final rawMaterialChoiceMap = <int, RawMaterialCatalogItem>{};
  final staffMembers = <MasterOption>[].obs;
  final productionLines = <MasterOption>[].obs;
  final rawMaterials = <MasterOption>[].obs;
  final selectedMovementTab = 0.obs;
  final savedEntries = <ScrapMovementEntry>[].obs;

  final selectedStaffId = RxnInt();
  final selectedProductionLineId = RxnInt();
  final selectedRawMaterialChoiceId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _syncInitialTab();
    _loadLookups();
  }

  void _syncInitialTab() {
    final args = Get.arguments;
    if (args is Map && args['initialTab'] is int) {
      selectedMovementTab.value = (args['initialTab'] as int).clamp(0, 1);
    }
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final results = await Future.wait([
        masterDataRepository.fetchStaff(),
        masterDataRepository.fetchProductionLines(),
        masterDataRepository.fetchRawMaterialCatalog(),
      ]);
      final staffOptions = results[0] as List<MasterOption>;
      final productionLineOptions = results[1] as List<MasterOption>;
      final rawMaterialOptions = results[2] as List<RawMaterialCatalogItem>;
      staffMembers.assignAll(staffOptions);
      productionLines.assignAll(productionLineOptions);
      rawMaterialCatalog
        ..clear()
        ..addAll(rawMaterialOptions);
      rawMaterials.assignAll(
        _buildRawMaterialChoiceOptions(rawMaterialOptions),
      );
      _clearInvalidSelections();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoadingMasters.value = false;
    }
  }

  @override
  Future<void> refreshScreen() async {
    errorMessage.value = null;
    await _loadLookups();
  }

  String? validateText(String? value, String label) =>
      FormValidators.requiredField(value, label);

  String? validateSelection(int? value, String label) =>
      (value == null || value <= 0) ? '$label is required' : null;

  void _clearInvalidSelections() {
    if (!_containsOption(staffMembers, selectedStaffId.value)) {
      selectedStaffId.value = null;
    }
    if (!_containsOption(productionLines, selectedProductionLineId.value)) {
      selectedProductionLineId.value = null;
    }
    if (!_containsOption(rawMaterials, selectedRawMaterialChoiceId.value)) {
      selectedRawMaterialChoiceId.value = null;
    }
  }

  bool _containsOption(List<MasterOption> options, int? value) {
    if (value == null || value <= 0) {
      return false;
    }
    return options.any((option) => option.id == value);
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

  RawMaterialCatalogItem? get selectedRawMaterialChoice {
    final choiceId = selectedRawMaterialChoiceId.value;
    if (choiceId == null) {
      return null;
    }
    return rawMaterialChoiceMap[choiceId];
  }

  bool get isScrapYardToProductionLine => selectedMovementTab.value == 0;

  String get fromLocation =>
      isScrapYardToProductionLine ? 'scrap_yard' : 'production_line';

  String get toLocation =>
      isScrapYardToProductionLine ? 'production_line' : 'scrap_yard';

  String get screenSubtitle => isScrapYardToProductionLine
      ? 'Capture the weighed scrap on the left while assigning the operator, production line, and raw material variant for inward furnace movement.'
      : 'Capture the weighed scrap on the left while assigning the operator, production line, and raw material variant for return movement back to the yard.';

  String get movementTitle => isScrapYardToProductionLine
      ? 'Scrap Yard to Production Line'
      : 'Production Line to Scrap Yard';

  String get movementSubtitle => isScrapYardToProductionLine
      ? 'This tab posts scrap from the yard into the selected production line using staff and raw material context.'
      : 'This tab posts scrap from the selected production line back into the scrap yard using staff and raw material context.';

  String get submitLabel =>
      isScrapYardToProductionLine ? 'Save Scrap Weighing' : 'Save Scrap Return';

  String get submittingMessage => isScrapYardToProductionLine
      ? 'Saving scrap movement...'
      : 'Saving scrap return...';

  void onMovementTabChanged(int index) {
    selectedMovementTab.value = index.clamp(0, 1);
  }

  String? get selectedStaffName {
    final id = selectedStaffId.value;
    if (id == null) {
      return null;
    }
    return staffMembers.firstWhereOrNull((item) => item.id == id)?.name;
  }

  String? get selectedProductionLineName {
    final id = selectedProductionLineId.value;
    if (id == null) {
      return null;
    }
    return productionLines.firstWhereOrNull((item) => item.id == id)?.name;
  }

  @override
  Map<String, dynamic> buildPayload() {
    final selectedMaterial = selectedRawMaterialChoice;
    return {
      'from': fromLocation,
      'to': toLocation,
      'production_line_id': selectedProductionLineId.value,
      'staff_name': selectedStaffName,
      'raw_material_id': selectedMaterial?.rawMaterialId,
      'raw_material_variant': selectedMaterial?.rawMaterialTypeName,
      'weight': netWeight,
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) {
    return workflowRepository.scrapWeighing(payload);
  }

  @override
  String buildSuccessMessage(Map<String, dynamic> response) {
    final data = extractResultData(response);
    final movementId = data['id']?.toString() ?? '-';
    final weight = data['weight']?.toString() ?? netWeight.toStringAsFixed(2);
    return isScrapYardToProductionLine
        ? 'Scrap movement recorded. Ref: $movementId | Weight: $weight'
        : 'Scrap return recorded. Ref: $movementId | Weight: $weight';
  }

  @override
  Future<void> afterSuccess(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    final result = extractResultData(response);
    savedEntries.insert(
      0,
      ScrapMovementEntry(
        referenceId: result['id']?.toString() ?? '-',
        directionLabel: movementTitle,
        staffName: selectedStaffName ?? '-',
        productionLineName: selectedProductionLineName ?? '-',
        rawMaterialLabel: selectedRawMaterialChoice?.displayLabel ?? '-',
        grossWeight: enteredGrossWeight,
        tareWeight: enteredTareWeight,
        netWeight: netWeight,
        recordedAt: recordedAtController.text.trim(),
      ),
    );
    _prepareNextEntry();
  }

  void removeSavedEntry(ScrapMovementEntry entry) {
    savedEntries.remove(entry);
  }

  void _prepareNextEntry() {
    tareWeightController.clear();
    if (!scaleService.isScaleConnected) {
      grossWeightController.clear();
    }
    recordedAtController.text = ApiDateTimeFormatter.now();
  }

  @override
  void disposeControllers() {
    recordedAtController.dispose();
    disposeGrossTareNetControllers();
  }
}

class ScrapMovementEntry {
  const ScrapMovementEntry({
    required this.referenceId,
    required this.directionLabel,
    required this.staffName,
    required this.productionLineName,
    required this.rawMaterialLabel,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.recordedAt,
  });

  final String referenceId;
  final String directionLabel;
  final String staffName;
  final String productionLineName;
  final String rawMaterialLabel;
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final String recordedAt;
}
