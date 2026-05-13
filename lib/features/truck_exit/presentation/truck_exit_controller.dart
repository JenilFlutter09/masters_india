import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
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
  final weighbridges = <MasterOption>[].obs;
  final selectedCustomerId = RxnInt();
  final selectedWeighbridgeId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingMasters.value = true;
    try {
      final customerOptions = await masterDataRepository.fetchCustomers();
      final weighbridgeOptions = await masterDataRepository.fetchWeighbridges();
      customers.assignAll(customerOptions);
      weighbridges.assignAll(weighbridgeOptions);
      _clearInvalidSelections();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoadingMasters.value = false;
    }
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

  String? validateWeightValue(String? value, String label) {
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

  String? validateReceiptOrInvoice() {
    if (receiptNoController.text.trim().isEmpty &&
        invoiceNoController.text.trim().isEmpty) {
      return 'Receipt number or invoice number is required';
    }
    return null;
  }

  void _clearInvalidSelections() {
    if (!_containsOption(customers, selectedCustomerId.value)) {
      selectedCustomerId.value = null;
    }
    if (!_containsOption(weighbridges, selectedWeighbridgeId.value)) {
      selectedWeighbridgeId.value = null;
    }
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
      if (receiptNoController.text.trim().isNotEmpty)
        'receipt_no': receiptNoController.text.trim(),
      if (invoiceNoController.text.trim().isNotEmpty)
        'invoice_no': invoiceNoController.text.trim(),
      'customer_id': selectedCustomerId.value,
      'weighbridge_id': selectedWeighbridgeId.value,
      'gross_weight': double.parse(grossWeightController.text.trim()),
      'tare_weight': double.parse(tareWeightController.text.trim()),
      'truck_no': truckNumberController.text.trim(),
      'weighed_at': weighedAtController.text.trim(),
    };
  }

  @override
  Future<void> submit() async {
    errorMessage.value = validateReceiptOrInvoice();
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
    final linked = data['linked_inward_id']?.toString() ?? '-';
    final netWeight = data['net_weight']?.toString() ?? '-';
    return 'Truck exit recorded. Linked inward: $linked | Net: $netWeight';
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
