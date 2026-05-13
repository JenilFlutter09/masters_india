import 'package:flutter/material.dart';

import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class MotherCoilDispatchController extends WorkflowFormController {
  MotherCoilDispatchController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final motherCoilIdController = TextEditingController();
  final dispatchedAtController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );

  String? validateText(String? value, String label) =>
      FormValidators.requiredField(value, label);

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

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'mother_coil_id': int.parse(motherCoilIdController.text.trim()),
      'dispatch_weight': enteredWeight,
      'dispatched_at': dispatchedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.dispatchMotherCoil(payload);

  @override
  void disposeControllers() {
    motherCoilIdController.dispose();
    dispatchedAtController.dispose();
  }
}
