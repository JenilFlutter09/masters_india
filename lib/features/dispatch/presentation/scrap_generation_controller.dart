import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class ScrapGenerationController extends WorkflowFormController {
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
  final productionLines = <MasterOption>[].obs;
  final selectedProductionLineId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      productionLines.assignAll(
        await masterDataRepository.fetchProductionLines(),
      );
      if (!_containsOption(productionLines, selectedProductionLineId.value)) {
        selectedProductionLineId.value = null;
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

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'production_line_id': selectedProductionLineId.value,
      'furnace_output_id': int.parse(furnaceOutputIdController.text.trim()),
      'weight': enteredWeight,
      'remarks': remarksController.text.trim(),
      'recorded_at': recordedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.scrapGeneration(payload);

  @override
  void disposeControllers() {
    furnaceOutputIdController.dispose();
    remarksController.dispose();
    recordedAtController.dispose();
  }
}
