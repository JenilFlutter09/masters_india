import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/master_option.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/data/master_data_repository.dart';
import '../../workflow/presentation/gross_tare_net_workflow_mixin.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class MotherCoilDispatchController extends WorkflowFormController
    with GrossTareNetWorkflowMixin {
  MotherCoilDispatchController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final masterDataRepository = Get.find<MasterDataRepository>();

  final motherCoilIdController = TextEditingController();
  final dispatchedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final barcodeFocusNode = FocusNode();
  final customers = <MasterOption>[].obs;
  final selectedCustomerId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadCustomers();
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

  @override
  Map<String, dynamic> buildPayload() {
    final barcodeOrId = motherCoilIdController.text.trim();
    return {
      'dispatch_type': 'mother_coil',
      'barcode': barcodeOrId,
      'mother_coil_id': parseMotherCoilId(motherCoilIdController.text.trim()),
      'customer_id': selectedCustomerId.value,
      'dispatch_weight': netWeight,
      'dispatched_at': dispatchedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.dispatch(payload);

  @override
  void disposeControllers() {
    motherCoilIdController.dispose();
    dispatchedAtController.dispose();
    barcodeFocusNode.dispose();
    disposeGrossTareNetControllers();
  }
}
