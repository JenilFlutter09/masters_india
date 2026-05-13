import 'package:flutter/material.dart';

import '../../../core/models/label_job.dart';
import '../../../core/utils/api_date_time_formatter.dart';
import '../../../core/utils/form_validators.dart';
import '../../workflow/presentation/workflow_form_controller.dart';

class BabyInwardController extends WorkflowFormController {
  BabyInwardController({
    required super.workflowRepository,
    required super.scaleService,
    required super.printerService,
  });

  final motherCoilIdController = TextEditingController();
  final itemTypeController = TextEditingController(text: 'Baby Coil');
  final createdOnController = TextEditingController(
    text: ApiDateTimeFormatter.now(),
  );
  final labelPrintedAtController = TextEditingController(
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
      'item_type': itemTypeController.text.trim(),
      'weight': enteredWeight,
      'created_on': createdOnController.text.trim(),
      'label_printed_at': labelPrintedAtController.text.trim(),
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
            'Item Type: ${request['item_type']}',
            'Weight: ${request['weight']} kg',
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
  }
}
