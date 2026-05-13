import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class DrossWeighingController extends WorkflowFormController {
  DrossWeighingController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final recordedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final productionLines = <MasterOption>[].obs;
  final drossTypes = <String>[].obs;
  final selectedProductionLineId = RxnInt();
  final selectedDrossType = RxnString();

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
        masterDataRepository.fetchDrossTypes(),
      ]);
      productionLines.assignAll(results[0] as List<MasterOption>);
      drossTypes.assignAll(results[1] as List<String>);
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

  String? validateTypeSelection(String? value, String label) =>
      (value == null || value.isEmpty) ? '$label is required' : null;

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
      'dross_type': selectedDrossType.value,
      'weight': enteredWeight,
      'recorded_at': recordedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) {
    return workflowRepository.drossInward(payload);
  }

  @override
  Future<void> afterSuccess(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    if (printerService.isPrinterConfigured &&
        printerService.isPrinterConnected) {
      await printerService.printLabel(
        printerService.buildDrossLabel(request: request, response: response),
      );
    }
  }

  @override
  void disposeControllers() {
    recordedAtController.dispose();
  }
}
