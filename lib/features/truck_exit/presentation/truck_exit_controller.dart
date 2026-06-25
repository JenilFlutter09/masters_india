import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/models/product_catalog_item.dart';
import '../../../core/models/raw_material_catalog_item.dart';
import '../../../core/models/truck_receipt_reference.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class TruckExitController extends WorkflowFormController {
  TruckExitController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final receiptNoController = TextEditingController();
  final invoiceNoController = TextEditingController();
  final truckNumberController = TextEditingController();
  final weighedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final grossWeightController = TextEditingController();
  final tareWeightController = TextEditingController();

  final customers = <MasterOption>[].obs;
  final rawMaterials = <MasterOption>[].obs;
  final drossTypes = <String>[].obs;
  final motherCoilProducts = <MasterOption>[].obs;
  final babyCoilProducts = <MasterOption>[].obs;
  final receiptReferences = <TruckReceiptReference>[].obs;
  final rawMaterialCatalog = <RawMaterialCatalogItem>[];
  final rawMaterialChoiceMap = <int, RawMaterialCatalogItem>{};
  final babyCoilProductCatalog = <ProductCatalogItem>[];

  final selectedExitTab = 0.obs;
  final selectedReceiptNumber = RxnString();
  final selectedCustomerId = RxnInt();
  final selectedFinishedGoodsType = RxnString();
  final selectedRawMaterialChoiceId = RxnInt();
  final selectedDrossType = RxnString();
  final selectedMotherCoilProductId = RxnInt();
  final selectedBabyCoilProductId = RxnInt();

  static const finishedGoodsTypes = <String>[
    'raw_material',
    'dross',
    'mother_coil',
    'baby_coil',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final results = await Future.wait([
        masterDataRepository.fetchTruckReceiptReferences(),
        masterDataRepository.fetchCustomers(),
        masterDataRepository.fetchRawMaterialCatalog(),
        masterDataRepository.fetchDrossTypes(),
        masterDataRepository.fetchMotherCoilProducts(),
        masterDataRepository.fetchBabyCoilProducts(),
      ]);
      final receiptOptions = results[0] as List<TruckReceiptReference>;
      final customerOptions = results[1] as List<MasterOption>;
      final rawMaterialOptions = results[2] as List<RawMaterialCatalogItem>;
      final drossTypeOptions = results[3] as List<String>;
      final motherCoilProductOptions = results[4] as List<MasterOption>;
      final babyCoilProductOptions = results[5] as List<ProductCatalogItem>;

      receiptReferences.assignAll(receiptOptions);
      customers.assignAll(customerOptions);
      rawMaterialCatalog
        ..clear()
        ..addAll(rawMaterialOptions);
      rawMaterials.assignAll(
        _buildRawMaterialChoiceOptions(rawMaterialOptions),
      );
      drossTypes.assignAll(drossTypeOptions);
      motherCoilProducts.assignAll(motherCoilProductOptions);
      babyCoilProductCatalog
        ..clear()
        ..addAll(babyCoilProductOptions);
      babyCoilProducts.assignAll(
        babyCoilProductOptions.map((item) => item.option).toList(),
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

  String? validateStringSelection(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

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

  String? validateReceiptOrInvoice() {
    if ((selectedReceiptNumber.value ?? '').trim().isEmpty) {
      return 'Receipt number is required';
    }
    final reference = selectedReceiptReference;
    if (reference == null) {
      return 'Select a valid receipt number';
    }
    return null;
  }

  void _clearInvalidSelections() {
    final receiptNumber = selectedReceiptNumber.value;
    if (receiptNumber != null &&
        !receiptReferences.any((item) => item.receiptNumber == receiptNumber)) {
      selectedReceiptNumber.value = null;
      receiptNoController.clear();
      invoiceNoController.clear();
      truckNumberController.clear();
    }
    if (!_containsOption(customers, selectedCustomerId.value)) {
      selectedCustomerId.value = null;
    }
    if (!_containsOption(rawMaterials, selectedRawMaterialChoiceId.value)) {
      selectedRawMaterialChoiceId.value = null;
    }
    if (!_containsOption(
      motherCoilProducts,
      selectedMotherCoilProductId.value,
    )) {
      selectedMotherCoilProductId.value = null;
    }
    if (!_containsOption(babyCoilProducts, selectedBabyCoilProductId.value)) {
      selectedBabyCoilProductId.value = null;
    }
    if (!drossTypes.contains(selectedDrossType.value)) {
      selectedDrossType.value = null;
    }
    if (!finishedGoodsTypes.contains(selectedFinishedGoodsType.value)) {
      selectedFinishedGoodsType.value = null;
    }
  }

  String? validateReceiptSelection(String? value) =>
      (value == null || value.trim().isEmpty)
      ? 'Receipt number is required'
      : null;

  List<String> get receiptNumbers =>
      receiptReferences.map((item) => item.receiptNumber).toSet().toList()
        ..sort();

  TruckReceiptReference? get selectedReceiptReference =>
      receiptReferences.firstWhereOrNull(
        (item) => item.receiptNumber == selectedReceiptNumber.value,
      );

  void onReceiptChanged(String? value) {
    selectedReceiptNumber.value = value;
    receiptNoController.text = value ?? '';

    final selectedReference = selectedReceiptReference;

    invoiceNoController.text = selectedReference?.invoiceNumber ?? '';
    truckNumberController.text = selectedReference?.truckNumber ?? '';
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

  ProductCatalogItem? get selectedBabyCoilProduct {
    final productId = selectedBabyCoilProductId.value;
    if (productId == null) {
      return null;
    }
    return babyCoilProductCatalog.firstWhereOrNull(
      (item) => item.id == productId,
    );
  }

  MasterOption? get selectedMotherCoilProduct => motherCoilProducts
      .firstWhereOrNull((item) => item.id == selectedMotherCoilProductId.value);

  bool get isDispatchTab => selectedExitTab.value == 0;
  bool get isEmptyExitTab => !isDispatchTab;

  String get exitTitle =>
      isDispatchTab ? 'Dispatch Release Details' : 'Empty Exit Details';

  String get exitSubtitle => isDispatchTab
      ? 'Select the receipt, assign the customer, and complete the finished-goods metadata required for weighbridge dispatch.'
      : 'Select the receipt and verify the linked invoice and truck details before posting the empty scrap unload exit.';

  String get weightStationSubtitle => isDispatchTab
      ? 'Capture the loaded dispatch gross and tare on the left before saving the finished-goods outbound entry.'
      : 'Use this panel to move the latest scale value into gross or tare before submitting the empty outbound truck exit.';

  String get submitLabel =>
      isDispatchTab ? 'Save Dispatch Exit' : 'Save Empty Exit';

  String get submittingMessage =>
      isDispatchTab ? 'Saving dispatch exit...' : 'Saving empty exit...';

  void onExitTabChanged(int index) {
    selectedExitTab.value = index.clamp(0, 1);
  }

  void onFinishedGoodsTypeChanged(String? value) {
    selectedFinishedGoodsType.value = value;
    selectedRawMaterialChoiceId.value = null;
    selectedDrossType.value = null;
    selectedMotherCoilProductId.value = null;
    selectedBabyCoilProductId.value = null;
  }

  String? validateDispatchConfiguration() {
    if (!isDispatchTab) {
      return null;
    }

    if (selectedCustomerId.value == null || selectedCustomerId.value! <= 0) {
      return 'Customer is required';
    }

    final goodsType = selectedFinishedGoodsType.value;
    if (goodsType == null || goodsType.isEmpty) {
      return 'Finished goods type is required';
    }

    switch (goodsType) {
      case 'raw_material':
        if (selectedRawMaterialChoice == null) {
          return 'Raw material is required';
        }
        break;
      case 'dross':
        if ((selectedDrossType.value ?? '').trim().isEmpty) {
          return 'Dross type is required';
        }
        break;
      case 'mother_coil':
        if (selectedMotherCoilProduct == null) {
          return 'Mother coil product is required';
        }
        break;
      case 'baby_coil':
        if (selectedBabyCoilProduct == null) {
          return 'Baby coil product is required';
        }
        break;
    }

    return null;
  }

  @override
  Map<String, dynamic> buildPayload() {
    final payload = <String, dynamic>{
      'exit_type': isDispatchTab
          ? 'finished_goods_dispatch'
          : 'scrap_unload_exit',
      'receipt_no': selectedReceiptNumber.value!.trim(),
      'gross_weight': double.parse(grossWeightController.text.trim()),
      'tare_weight': double.tryParse(tareWeightController.text.trim()) ?? 0,
    };

    if (!isDispatchTab) {
      return payload;
    }

    final goodsType = selectedFinishedGoodsType.value!;
    payload.addAll({
      'customer_id': selectedCustomerId.value,
      'finished_goods_type': goodsType,
    });

    switch (goodsType) {
      case 'raw_material':
        final selectedMaterial = selectedRawMaterialChoice;
        payload['raw_material_name'] = selectedMaterial?.rawMaterialName;
        payload['raw_material_variant'] = selectedMaterial?.rawMaterialTypeName;
        break;
      case 'dross':
        payload['dross_type'] = selectedDrossType.value;
        break;
      case 'mother_coil':
        payload['mother_product_name'] = selectedMotherCoilProduct?.name;
        break;
      case 'baby_coil':
        payload['baby_product_name'] = selectedBabyCoilProduct?.name;
        break;
    }

    return payload;
  }

  @override
  Future<void> submit() async {
    errorMessage.value =
        validateReceiptOrInvoice() ?? validateDispatchConfiguration();
    if (errorMessage.value != null) {
      return;
    }
    await super.submit();
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) {
    return workflowRepository.weighbridgeOutbound(payload);
  }

  @override
  String buildSuccessMessage(Map<String, dynamic> response) {
    final data = extractResultData(response);
    final netWeight = data['net_weight']?.toString() ?? '-';
    if (isDispatchTab) {
      final outboundId = data['id']?.toString() ?? '-';
      return 'Dispatch exit recorded. Ref: $outboundId | Net: $netWeight';
    }
    final linked = data['linked_inward_id']?.toString() ?? '-';
    return 'Empty truck exit recorded. Linked inward: $linked | Net: $netWeight';
  }

  @override
  void disposeControllers() {
    receiptNoController.dispose();
    invoiceNoController.dispose();
    truckNumberController.dispose();
    weighedAtController.dispose();
    grossWeightController.dispose();
    tareWeightController.dispose();
  }
}
