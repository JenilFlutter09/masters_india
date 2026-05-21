import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/available_mother_coil_item.dart';
import '../../../core/models/label_job.dart';
import '../../../core/models/master_option.dart';
import '../../../core/models/product_catalog_item.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/gross_tare_net_workflow_mixin.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class BabyInwardController extends WorkflowFormController
    with GrossTareNetWorkflowMixin {
  BabyInwardController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final motherCoilIdController = TextEditingController();
  final itemTypeController = TextEditingController(text: 'Baby Coil');
  final createdOnController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final labelPrintedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final availableMotherCoils = <MasterOption>[].obs;
  final availableMotherCoilCatalog = <AvailableMotherCoilItem>[];
  final babyProducts = <MasterOption>[].obs;
  final babyProductCatalog = <ProductCatalogItem>[];
  final selectedMotherCoilId = RxnInt();
  final selectedBabyProductId = RxnInt();
  final parameterKeys = <String>[].obs;
  final parameterControllers = <String, TextEditingController>{};

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final results = await Future.wait([
        masterDataRepository.fetchAvailableMotherCoils(),
        masterDataRepository.fetchBabyCoilProducts(),
      ]);
      final motherCoils = results[0] as List<AvailableMotherCoilItem>;
      final products = results[1] as List<ProductCatalogItem>;
      availableMotherCoilCatalog
        ..clear()
        ..addAll(motherCoils);
      availableMotherCoils.assignAll(
        motherCoils.map((item) => item.option).toList(),
      );
      babyProductCatalog
        ..clear()
        ..addAll(products);
      babyProducts.assignAll(products.map((item) => item.option).toList());
      if (!_containsOption(availableMotherCoils, selectedMotherCoilId.value)) {
        selectedMotherCoilId.value = null;
      }
      if (!_containsOption(babyProducts, selectedBabyProductId.value)) {
        selectedBabyProductId.value = null;
      }
      _syncSelectedMotherCoil();
      _syncParameterControllers();
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

  ProductCatalogItem? get selectedBabyProduct => babyProductCatalog
      .firstWhereOrNull((item) => item.id == selectedBabyProductId.value);

  AvailableMotherCoilItem? get selectedMotherCoil => availableMotherCoilCatalog
      .firstWhereOrNull((item) => item.id == selectedMotherCoilId.value);

  void onMotherCoilChanged(int? value) {
    selectedMotherCoilId.value = value;
    _syncSelectedMotherCoil();
  }

  void onBabyProductChanged(int? value) {
    selectedBabyProductId.value = value;
    _syncParameterControllers();
  }

  void _syncParameterControllers() {
    final parameters = selectedBabyProduct?.parameters ?? const <String>[];
    parameterKeys.assignAll(parameters);

    final validKeys = parameters.toSet();
    final obsoleteKeys = parameterControllers.keys
        .where((key) => !validKeys.contains(key))
        .toList();
    for (final key in obsoleteKeys) {
      parameterControllers.remove(key)?.dispose();
    }

    for (final key in parameters) {
      parameterControllers.putIfAbsent(key, TextEditingController.new);
    }
  }

  Map<String, String> buildParameterValues() {
    final values = <String, String>{};
    for (final key in parameterKeys) {
      final value = parameterControllers[key]?.text.trim() ?? '';
      if (value.isNotEmpty) {
        values[key] = value;
      }
    }
    return values;
  }

  void _syncSelectedMotherCoil() {
    final selected = selectedMotherCoil;
    motherCoilIdController.text = selected == null
        ? ''
        : selected.id.toString();
  }

  @override
  Map<String, dynamic> buildPayload() {
    final selectedCoil = selectedMotherCoil;
    final selectedProduct = selectedBabyProduct;
    return {
      'mother_coil_id':
          selectedCoil?.id ?? int.parse(motherCoilIdController.text.trim()),
      'item_type': itemTypeController.text.trim(),
      'mother_product_name': selectedCoil?.productName,
      'product_name': selectedProduct?.name,
      'parameter_values': buildParameterValues(),
      'gross_weight': enteredGrossWeight,
      'tare_weight': enteredTareWeight,
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.babyInward(payload);

  @override
  Future<void> afterSuccess(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    final result = extractResultData(response);
    if (printerService.isPrinterConfigured &&
        printerService.isPrinterConnected) {
      await printerService.printLabel(
        LabelJob(
          title: 'Baby Product Label',
          barcodeValue: result['barcode']?.toString(),
          lines: [
            'Mother Coil ID: ${request['mother_coil_id']}',
            'Product: ${request['product_name'] ?? request['item_type']}',
            'Weight: ${netWeight.toStringAsFixed(2)} kg',
          ],
        ),
      );
    }
  }

  @override
  void disposeControllers() {
    motherCoilIdController.dispose();
    itemTypeController.dispose();
    createdOnController.dispose();
    labelPrintedAtController.dispose();
    for (final controller in parameterControllers.values) {
      controller.dispose();
    }
    disposeGrossTareNetControllers();
  }
}
