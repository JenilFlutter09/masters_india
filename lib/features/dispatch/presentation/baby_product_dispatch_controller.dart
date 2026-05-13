import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class BabyProductDispatchController extends WorkflowFormController {
  BabyProductDispatchController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final barcodeController = TextEditingController();
  final dispatchedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final customers = <MasterOption>[].obs;
  final selectedCustomerId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
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
      'barcode': barcodeController.text.trim(),
      'customer_id': selectedCustomerId.value,
      'dispatch_weight': enteredWeight,
      'dispatched_at': dispatchedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.dispatchBabyProduct(payload);

  @override
  void disposeControllers() {
    barcodeController.dispose();
    dispatchedAtController.dispose();
  }
}
