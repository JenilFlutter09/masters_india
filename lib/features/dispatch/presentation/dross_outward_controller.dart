import 'package:flutter/material.dart';

import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class DrossOutwardController extends WorkflowFormController {
  DrossOutwardController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final drossInwardIdController = TextEditingController();
  final recordedAtController = TextEditingController(
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
      'dross_inward_id': int.parse(drossInwardIdController.text.trim()),
      'outward_weight': enteredWeight,
      'recorded_at': recordedAtController.text.trim(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload) =>
      workflowRepository.drossOutward(payload);

  @override
  void disposeControllers() {
    drossInwardIdController.dispose();
    recordedAtController.dispose();
  }
}
