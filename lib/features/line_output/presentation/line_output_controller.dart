import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class LineOutputController extends WorkflowFormController {
  LineOutputController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final outputType = 'Rod'.obs;
  final cctvRefController = TextEditingController();
  final producedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final labelPrintedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );

  final productionLines = <MasterOption>[].obs;
  final metalAlloys = <MasterOption>[].obs;
  final selectedProductionLineId = RxnInt();
  final selectedMetalAlloyId = RxnInt();

  bool get isRod => outputType.value == 'Rod';

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final productionLineOptions = await masterDataRepository
          .fetchProductionLines();
      final metalAlloyOptions = await masterDataRepository.fetchMetalAlloys();
      productionLines.assignAll(productionLineOptions);
      metalAlloys.assignAll(metalAlloyOptions);
      if (!_containsOption(productionLines, selectedProductionLineId.value)) {
        selectedProductionLineId.value = null;
      }
      if (!_containsOption(metalAlloys, selectedMetalAlloyId.value)) {
        selectedMetalAlloyId.value = null;
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoadingMasters.value = false;
    }
  }

  void setOutputType(String? value) {
    if (value != null) {
      outputType.value = value;
    }
  }

  String? validateText(String? value, String label) =>
      FormValidators.requiredField(value, label);

  String? validateSelection(int? value, String label) =>
      (value == null || value <= 0) ? '$label is required' : null;

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
      'metal_alloy_id': selectedMetalAlloyId.value,
      'production_type': outputType.value,
      'issue_weight': enteredWeight,
      if (cctvRefController.text.trim().isNotEmpty)
        'cctv_ref': cctvRefController.text.trim(),
      'produced_at': producedAtController.text.trim(),
      'label_printed_at': labelPrintedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) {
    return workflowRepository.furnaceOutput(payload);
  }

  @override
  Future<void> afterSuccess(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    if (printerService.isPrinterConfigured &&
        printerService.isPrinterConnected) {
      await printerService.printLabel(
        printerService.buildMotherCoilLabel(
          request: request,
          response: response,
        ),
      );
    }
  }

  @override
  void disposeControllers() {
    cctvRefController.dispose();
    producedAtController.dispose();
    labelPrintedAtController.dispose();
  }
}
