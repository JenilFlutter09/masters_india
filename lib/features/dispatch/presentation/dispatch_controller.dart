import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/available_mother_coil_item.dart';
import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class DispatchController extends WorkflowFormController {
  DispatchController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final motherCoilBarcodeController = TextEditingController();
  final babyProductBarcodeController = TextEditingController();
  final motherCoilFocusNode = FocusNode();
  final babyProductFocusNode = FocusNode();
  final dispatchedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );

  final customers = <MasterOption>[].obs;
  final availableMotherCoils = <MasterOption>[].obs;
  final availableMotherCoilCatalog = <AvailableMotherCoilItem>[];
  final savedEntries = <DispatchEntry>[].obs;
  final selectedCustomerId = RxnInt();
  final selectedDispatchTab = 0.obs;

  bool get isMotherCoilTab => selectedDispatchTab.value == 0;
  bool get isBabyProductTab => !isMotherCoilTab;

  @override
  void onInit() {
    super.onInit();
    _syncInitialTab();
    _loadCustomers();
  }

  void _syncInitialTab() {
    final args = Get.arguments;
    if (args is Map && args['initialTab'] is int) {
      selectedDispatchTab.value = (args['initialTab'] as int).clamp(0, 1);
      return;
    }
    if (Get.currentRoute == AppRoutes.babyProductDispatch) {
      selectedDispatchTab.value = 1;
    }
  }

  Future<void> _loadCustomers() async {
    isLoadingMasters.value = true;
    try {
      customers.assignAll(await masterDataRepository.fetchCustomers());
      if (!_containsOption(customers, selectedCustomerId.value)) {
        selectedCustomerId.value = null;
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
    isLoadingMasters.value = true;
    try {
      final results = await Future.wait([
        masterDataRepository.fetchCustomers(),
        masterDataRepository.fetchAvailableMotherCoils(),
      ]);
      customers.assignAll(results[0] as List<MasterOption>);
      final motherCoils = results[1] as List<AvailableMotherCoilItem>;
      availableMotherCoilCatalog
        ..clear()
        ..addAll(motherCoils);
      availableMotherCoils.assignAll(
        motherCoils.map((item) => item.option).toList(),
      );
      if (!_containsOption(customers, selectedCustomerId.value)) {
        selectedCustomerId.value = null;
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoadingMasters.value = false;
    }
  }

  void onDispatchTabChanged(int index) {
    selectedDispatchTab.value = index.clamp(0, 1);
  }

  String? validateText(String? value, String label) =>
      FormValidators.requiredField(value, label);

  String? validateSelection(int? value, String label) =>
      (value == null || value <= 0) ? '$label is required' : null;

  String? validateCoilBarcodeOrId(String? value, String label) {
    final required = FormValidators.requiredField(value, label);
    if (required != null) {
      return required;
    }
    final parsed = parseMotherCoilId(value!.trim());
    if (parsed == null || parsed <= 0) {
      return '$label must include a valid mother coil identifier';
    }
    return null;
  }

  int? parseMotherCoilId(String raw) {
    final trimmed = raw.trim();
    final direct = int.tryParse(trimmed);
    if (direct != null && direct > 0) {
      return direct;
    }

    final matches = RegExp(r'(\d+)').allMatches(trimmed).toList();
    if (matches.isEmpty) {
      return null;
    }
    return int.tryParse(matches.last.group(1)!);
  }

  bool _containsOption(List<MasterOption> options, int? value) {
    if (value == null || value <= 0) {
      return false;
    }
    return options.any((option) => option.id == value);
  }

  MasterOption? get selectedCustomer =>
      customers.firstWhereOrNull((item) => item.id == selectedCustomerId.value);

  String get pageTitle =>
      isMotherCoilTab ? 'Mother Coil Dispatch' : 'Baby Product Dispatch';

  String get pageSubtitle => isMotherCoilTab
      ? 'Scan the mother coil barcode, confirm the customer, and dispatch the selected coil without a weighbridge step.'
      : 'Scan the baby product barcode, confirm the customer, and dispatch the selected item without a weighbridge step.';

  String get detailsSubtitle => isMotherCoilTab
      ? 'Use the hardware scanner or type the mother coil reference, then assign the dispatch customer and confirm the parsed coil ID.'
      : 'Use the hardware scanner or type the baby product barcode, then assign the dispatch customer and confirm the scanned value.';

  String get scannerPanelTitle =>
      isMotherCoilTab ? 'Mother Coil Scanner' : 'Baby Product Scanner';

  String get scannerPanelSubtitle => isMotherCoilTab
      ? 'This dispatch flow uses the scanned coil barcode to derive the mother coil identifier and submit the outbound record.'
      : 'This dispatch flow uses the scanned product barcode to submit the outbound record directly from the scanner station.';

  String get dispatchModeLabel =>
      isMotherCoilTab ? 'Mother Coil Dispatch' : 'Baby Product Dispatch';

  String get primaryFieldLabel =>
      isMotherCoilTab ? 'Mother Coil Barcode / ID' : 'Product Barcode';

  String get primaryFieldHint => isMotherCoilTab
      ? 'Scan barcode or enter mother coil reference'
      : 'Scan barcode from the dispatched product';

  TextEditingController get activeCodeController => isMotherCoilTab
      ? motherCoilBarcodeController
      : babyProductBarcodeController;

  FocusNode get activeFocusNode =>
      isMotherCoilTab ? motherCoilFocusNode : babyProductFocusNode;

  void applyScannedCode(String code) {
    activeCodeController.text = code.trim();
  }

  String get scanSummaryValue {
    final value = activeCodeController.text.trim();
    if (value.isEmpty) {
      return isMotherCoilTab
          ? 'Awaiting mother coil scan'
          : 'Awaiting baby product scan';
    }
    return value;
  }

  String get identifierSummaryValue {
    if (isBabyProductTab) {
      return scanSummaryValue;
    }
    final parsed = parseMotherCoilId(motherCoilBarcodeController.text.trim());
    return parsed?.toString() ?? 'No valid mother coil ID detected yet';
  }

  @override
  Map<String, dynamic> buildPayload() {
    final barcodeValue = activeCodeController.text.trim();
    if (isMotherCoilTab) {
      return {
        'dispatch_type': 'mother_coil',
        'barcode': barcodeValue,
        'mother_coil_id': parseMotherCoilId(barcodeValue),
        'customer_id': selectedCustomerId.value,
        'dispatched_at': dispatchedAtController.text.trim(),
      };
    }

    return {
      'dispatch_type': 'baby_product',
      'barcode': barcodeValue,
      'customer_id': selectedCustomerId.value,
      'dispatched_at': dispatchedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.dispatch(payload);

  @override
  Future<void> afterSuccess(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    final result = extractResultData(response);
    savedEntries.insert(
      0,
      DispatchEntry(
        referenceId:
            result['dispatch_ref']?.toString() ??
            result['id']?.toString() ??
            '-',
        dispatchLabel: dispatchModeLabel,
        scannedValue: request['barcode']?.toString() ?? '-',
        resolvedIdentifier: isMotherCoilTab
            ? (request['mother_coil_id']?.toString() ?? '-')
            : (result['barcode']?.toString() ??
                  request['barcode']?.toString() ??
                  '-'),
        customerName: selectedCustomer?.name ?? '-',
        dispatchedAt: request['dispatched_at']?.toString() ?? '-',
      ),
    );
    _prepareNextEntry();
  }

  @override
  String buildSuccessMessage(Map<String, dynamic> response) {
    final data = extractResultData(response);
    final reference =
        data['dispatch_ref']?.toString() ??
        data['id']?.toString() ??
        data['barcode']?.toString() ??
        '-';
    return isMotherCoilTab
        ? 'Mother coil dispatch recorded. Ref: $reference'
        : 'Baby product dispatch recorded. Ref: $reference';
  }

  void removeSavedEntry(DispatchEntry entry) {
    savedEntries.remove(entry);
  }

  void _prepareNextEntry() {
    activeCodeController.clear();
    dispatchedAtController.text = ApiDateTimeFormatter.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!activeFocusNode.hasFocus) {
        activeFocusNode.requestFocus();
      }
    });
  }

  @override
  void disposeControllers() {
    motherCoilBarcodeController.dispose();
    babyProductBarcodeController.dispose();
    motherCoilFocusNode.dispose();
    babyProductFocusNode.dispose();
    dispatchedAtController.dispose();
  }
}

class DispatchEntry {
  const DispatchEntry({
    required this.referenceId,
    required this.dispatchLabel,
    required this.scannedValue,
    required this.resolvedIdentifier,
    required this.customerName,
    required this.dispatchedAt,
  });

  final String referenceId;
  final String dispatchLabel;
  final String scannedValue;
  final String resolvedIdentifier;
  final String customerName;
  final String dispatchedAt;
}
