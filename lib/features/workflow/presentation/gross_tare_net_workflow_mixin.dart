import 'package:flutter/material.dart';

import '../../../core/utils/form_validators.dart';
import 'workflow_form_controller.dart';

mixin GrossTareNetWorkflowMixin on WorkflowFormController {
  final grossWeightController = TextEditingController();
  final tareWeightController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    grossWeightController.addListener(_syncNetWeight);
    tareWeightController.addListener(_syncNetWeight);
    _syncNetWeight();
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

  double get enteredGrossWeight =>
      double.tryParse(grossWeightController.text.trim()) ?? 0;

  double get enteredTareWeight =>
      double.tryParse(tareWeightController.text.trim()) ?? 0;

  double get netWeight => enteredGrossWeight - enteredTareWeight;

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

  @override
  Future<void> submit() async {
    errorMessage.value = null;
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (netWeight <= 0) {
      errorMessage.value = 'Net weight must be greater than zero.';
      return;
    }
    await super.submit();
  }

  void disposeGrossTareNetControllers() {
    grossWeightController.removeListener(_syncNetWeight);
    tareWeightController.removeListener(_syncNetWeight);
    grossWeightController.dispose();
    tareWeightController.dispose();
  }

  void _syncNetWeight() {
    final nextValue = netWeight > 0 ? netWeight.toStringAsFixed(2) : '';
    if (weightController.text.trim() == nextValue) {
      return;
    }
    weightController.text = nextValue;
  }
}
