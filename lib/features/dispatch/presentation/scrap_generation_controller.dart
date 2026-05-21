import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/models/raw_material_catalog_item.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/gross_tare_net_workflow_mixin.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class ScrapGenerationController extends WorkflowFormController
    with GrossTareNetWorkflowMixin {
  ScrapGenerationController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final furnaceOutputIdController = TextEditingController();
  final remarksController = TextEditingController();
  final recordedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final rawMaterialCatalog = <RawMaterialCatalogItem>[];
  final rawMaterialChoiceMap = <int, RawMaterialCatalogItem>{};
  final staffMembers = <MasterOption>[].obs;
  final productionLines = <MasterOption>[].obs;
  final rawMaterials = <MasterOption>[].obs;
  final selectedStaffId = RxnInt();
  final selectedProductionLineId = RxnInt();
  final selectedRawMaterialChoiceId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final results = await Future.wait([
        masterDataRepository.fetchProductionLines(),
        masterDataRepository.fetchStaff(),
        masterDataRepository.fetchRawMaterialCatalog(),
      ]);
      productionLines.assignAll(results[0] as List<MasterOption>);
      staffMembers.assignAll(results[1] as List<MasterOption>);
      final rawMaterialOptions = results[2] as List<RawMaterialCatalogItem>;
      rawMaterialCatalog
        ..clear()
        ..addAll(rawMaterialOptions);
      rawMaterials.assignAll(
        _buildRawMaterialChoiceOptions(rawMaterialOptions),
      );
      if (!_containsOption(productionLines, selectedProductionLineId.value)) {
        selectedProductionLineId.value = null;
      }
      if (!_containsOption(staffMembers, selectedStaffId.value)) {
        selectedStaffId.value = null;
      }
      if (!_containsOption(rawMaterials, selectedRawMaterialChoiceId.value)) {
        selectedRawMaterialChoiceId.value = null;
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoadingMasters.value = false;
    }
  }

  String? validateText(String? value, String label) =>
      FormValidators.requiredField(value, label);

  String? validateSelection(int? value, String label) =>
      (value == null || value <= 0) ? '$label is required' : null;

  String? validateIntegerValue(String? value, String label) {
    final required = FormValidators.requiredField(value, label);
    if (required != null) {
      return required;
    }
    final parsed = int.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return '$label must be a valid number';
    }
    return null;
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

  String? get selectedStaffName {
    final id = selectedStaffId.value;
    if (id == null) {
      return null;
    }
    return staffMembers.firstWhereOrNull((item) => item.id == id)?.name;
  }

  @override
  Map<String, dynamic> buildPayload() {
    final selectedMaterial = selectedRawMaterialChoice;
    return {
      'from': 'production_line',
      'to': 'scrap_yard',
      'production_line_id': selectedProductionLineId.value,
      'staff_name': selectedStaffName,
      'raw_material_id': selectedMaterial?.rawMaterialId,
      'raw_material_variant': selectedMaterial?.rawMaterialTypeName,
      'weight': netWeight,
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.scrapWeighing(payload);

  @override
  void disposeControllers() {
    furnaceOutputIdController.dispose();
    remarksController.dispose();
    recordedAtController.dispose();
    disposeGrossTareNetControllers();
  }
}
