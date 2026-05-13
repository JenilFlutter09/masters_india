import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class LineInputController extends WorkflowFormController {
  LineInputController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final inwardEntryIdController = TextEditingController();
  final cctvRefController = TextEditingController();
  final issuedAtController = TextEditingController(
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
      'rm_inward_entry_id': int.parse(inwardEntryIdController.text.trim()),
      'production_line_id': selectedProductionLineId.value,
      'weight': enteredWeight,
      if (cctvRefController.text.trim().isNotEmpty)
        'cctv_ref': cctvRefController.text.trim(),
      'issued_at': issuedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) {
    return workflowRepository.scrapToFurnace(payload);
  }

  @override
  void disposeControllers() {
    inwardEntryIdController.dispose();
    cctvRefController.dispose();
    issuedAtController.dispose();
  }
}
