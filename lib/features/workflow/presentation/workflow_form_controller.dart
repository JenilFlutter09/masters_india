import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/app_exception.dart';
import '../../../core/models/scale_reading.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/services/scale_service.dart';
import '../../../core/utils/form_validators.dart';
import '../data/workflow_repository.dart';

abstract class WorkflowFormController extends GetxController {
  WorkflowFormController({
    required WorkflowRepository workflowRepository,
    required ScaleService scaleService,
    required PrinterService printerService,
  }) : _workflowRepository = workflowRepository,
       _scaleService = scaleService,
       _printerService = printerService;

  final WorkflowRepository _workflowRepository;
  final ScaleService _scaleService;
  final PrinterService _printerService;

  final formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
  final useManualWeight = true.obs;
  final isSubmitting = false.obs;
  final liveReading = Rxn<ScaleReading>();
  final errorMessage = RxnString();
  final successMessage = RxnString();
  final submissionResult = Rxn<Map<String, dynamic>>();
  final isLoadingMasters = false.obs;

  StreamSubscription<ScaleReading?>? _readingSubscription;

  WorkflowRepository get workflowRepository => _workflowRepository;
  ScaleService get scaleService => _scaleService;
  PrinterService get printerService => _printerService;

  String get scaleStatus => _scaleService.deviceStatus;
  String get printerStatus => _printerService.deviceStatus;

  String? weightValidator(String? value) {
    final required = FormValidators.requiredField(value, 'Weight');
    if (required != null) {
      return required;
    }
    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return 'Weight must be a valid number';
    }
    return null;
  }

  void toggleManualWeight(bool value) {
    useManualWeight.value = value;
    if (!value) {
      captureLiveWeight();
    }
  }

  void captureLiveWeight() {
    final reading = liveReading.value;
    if (reading != null) {
      weightController.text = reading.weight.toStringAsFixed(2);
    }
  }

  double get enteredWeight =>
      double.tryParse(weightController.text.trim()) ?? 0;

  @override
  void onInit() {
    super.onInit();
    useManualWeight.value = !_scaleService.isScaleConfigured;
    liveReading.value = _scaleService.currentReading.value;
    _readingSubscription = _scaleService.currentReading.listen((reading) {
      liveReading.value = reading;
      if (!useManualWeight.value && reading != null) {
        weightController.text = reading.weight.toStringAsFixed(2);
      }
    });
  }

  @override
  void onClose() {
    _readingSubscription?.cancel();
    weightController.dispose();
    disposeControllers();
    super.onClose();
  }

  Future<void> submit() async {
    errorMessage.value = null;
    successMessage.value = null;
    submissionResult.value = null;
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSubmitting.value = true;
    Map<String, dynamic>? payload;
    try {
      payload = buildPayload();
      final response = await submitWorkflow(payload);
      submissionResult.value = extractResultData(response);
      successMessage.value = buildSuccessMessage(response);
      _showSubmissionToast(
        title: 'Success',
        message: successMessage.value!,
        isError: false,
      );

      try {
        await afterSuccess(payload, response);
      } catch (error, stackTrace) {
        AppLogger.error(
          '[${runtimeType.toString()}] Post-success action failed.',
          error: error,
          stackTrace: stackTrace,
        );
        AppLogger.debug(
          '[${runtimeType.toString()}] Request payload:\n'
          '${AppLogger.prettyObject(payload)}',
        );
      }
    } on AppException catch (error, stackTrace) {
      errorMessage.value = error.message;
      _showSubmissionToast(
        title: 'Submission failed',
        message: error.message,
        isError: true,
      );
      _logSubmissionFailure(
        error: error,
        stackTrace: stackTrace,
        payload: payload,
      );
    } catch (error, stackTrace) {
      errorMessage.value = error.toString();
      _showSubmissionToast(
        title: 'Submission failed',
        message: errorMessage.value!,
        isError: true,
      );
      _logSubmissionFailure(
        error: error,
        stackTrace: stackTrace,
        payload: payload,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSubmissionToast({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      colorText: Colors.white,
    );
  }

  void _logSubmissionFailure({
    required Object error,
    required StackTrace stackTrace,
    Map<String, dynamic>? payload,
  }) {
    AppLogger.error(
      '[${runtimeType.toString()}] Submission failed.',
      error: error,
      stackTrace: stackTrace,
    );
    if (payload != null) {
      AppLogger.debug(
        '[${runtimeType.toString()}] Request payload:\n'
        '${AppLogger.prettyObject(payload)}',
      );
    }
  }

  Future<void> afterSuccess(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {}

  Map<String, dynamic> extractResultData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.cast<String, dynamic>();
    }
    return response;
  }

  String buildSuccessMessage(Map<String, dynamic> response) {
    return response['message']?.toString() ??
        'Workflow completed successfully.';
  }

  Map<String, dynamic> buildPayload();
  Future<Map<String, dynamic>> submitWorkflow(Map<String, dynamic> payload);
  void disposeControllers() {}
}
