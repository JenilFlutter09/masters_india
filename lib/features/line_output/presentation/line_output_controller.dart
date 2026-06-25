import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/models/production_line_catalog_item.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/gross_tare_net_workflow_mixin.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class LineOutputController extends WorkflowFormController
    with GrossTareNetWorkflowMixin {
  LineOutputController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final productionLineCatalog = <ProductionLineCatalogItem>[];
  final motherCoilProducts = <MasterOption>[].obs;
  final productionLines = <MasterOption>[].obs;
  final metalAlloys = <MasterOption>[].obs;
  final selectedProductionLineId = RxnInt();
  final selectedMetalAlloyId = RxnInt();
  final selectedMotherCoilProductId = RxnInt();
  final lastCreatedMotherCoilId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final results = await Future.wait([
        masterDataRepository.fetchProductionLineCatalog(),
        masterDataRepository.fetchMetalAlloys(),
        masterDataRepository.fetchMotherCoilProducts(),
      ]);
      final productionLineOptions =
          results[0] as List<ProductionLineCatalogItem>;
      final metalAlloyOptions = results[1] as List<MasterOption>;
      final motherCoilProductOptions = results[2] as List<MasterOption>;
      productionLineCatalog
        ..clear()
        ..addAll(productionLineOptions);
      productionLines.assignAll(
        productionLineOptions.map((item) => item.option).toList(),
      );
      metalAlloys.assignAll(metalAlloyOptions);
      motherCoilProducts.assignAll(motherCoilProductOptions);
      if (!_containsOption(productionLines, selectedProductionLineId.value)) {
        selectedProductionLineId.value = null;
      }
      if (!_containsOption(metalAlloys, selectedMetalAlloyId.value)) {
        selectedMetalAlloyId.value = null;
      }
      if (!_containsOption(
        motherCoilProducts,
        selectedMotherCoilProductId.value,
      )) {
        selectedMotherCoilProductId.value = null;
      }
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

  void onProductionLineChanged(int? value) {
    selectedProductionLineId.value = value;
    final selectedLine = selectedProductionLine;
    final assignedProduct =
        selectedLine?.productName?.trim().toLowerCase() ?? '';
    if (assignedProduct.isEmpty) {
      return;
    }
    final matchingProduct = motherCoilProducts.firstWhereOrNull(
      (item) => item.name.trim().toLowerCase() == assignedProduct,
    );
    if (matchingProduct != null) {
      selectedMotherCoilProductId.value = matchingProduct.id;
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

  ProductionLineCatalogItem? get selectedProductionLine => productionLineCatalog
      .firstWhereOrNull((item) => item.id == selectedProductionLineId.value);

  MasterOption? get selectedMotherCoilProduct => motherCoilProducts
      .firstWhereOrNull((item) => item.id == selectedMotherCoilProductId.value);

  String? get lineAssignedProductName {
    final product = selectedProductionLine?.productName?.trim();
    if (product == null || product.isEmpty) {
      return null;
    }
    return product;
  }

  bool get canUndoLatestOutput =>
      (lastCreatedMotherCoilId.value ?? 0) > 0 && !isSubmitting.value;

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'production_line_id': selectedProductionLineId.value,
      'metal_alloy_id': selectedMetalAlloyId.value,
      'mother_coil_product_id': selectedMotherCoilProductId.value,
      'gross_weight': enteredGrossWeight,
      'tare_weight': enteredTareWeight,
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
    final data = extractResultData(response);
    final motherCoilId = data['mother_coil_id'];
    if (motherCoilId is num) {
      lastCreatedMotherCoilId.value = motherCoilId.toInt();
    } else if (motherCoilId is String) {
      lastCreatedMotherCoilId.value = int.tryParse(motherCoilId.trim());
    }
  }

  @override
  String buildSuccessMessage(Map<String, dynamic> response) {
    final data = extractResultData(response);
    final productionRef = data['production_ref']?.toString() ?? '-';
    final coilNo = data['mother_coil_no']?.toString() ?? '-';
    final netWeight = data['net_weight']?.toString() ?? '-';
    return 'Mother coil inward created. Ref: $productionRef | Coil: $coilNo | Net: $netWeight';
  }

  Future<void> undoLatestOutput() async {
    final motherCoilId = lastCreatedMotherCoilId.value;
    if (motherCoilId == null || motherCoilId <= 0) {
      errorMessage.value = 'No mother coil output is available to undo.';
      return;
    }

    errorMessage.value = null;
    successMessage.value = null;
    isSubmitting.value = true;
    try {
      final response = await workflowRepository.furnaceOutput({
        'undo': true,
        'mother_coil_id': motherCoilId,
      });
      submissionResult.value = extractResultData(response);
      successMessage.value =
          response['message']?.toString() ??
          'Mother coil output undone successfully.';
      lastCreatedMotherCoilId.value = null;
      Get.closeAllSnackbars();
      Get.snackbar(
        'Undo successful',
        successMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (error) {
      errorMessage.value = error.toString();
      Get.closeAllSnackbars();
      Get.snackbar(
        'Undo failed',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void disposeControllers() {
    disposeGrossTareNetControllers();
  }
}
