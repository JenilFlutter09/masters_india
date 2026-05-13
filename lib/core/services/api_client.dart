import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/app_exception.dart';
import 'app_logger.dart';
import 'app_config_service.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient({
    required AppConfigService appConfigService,
    required StorageService storageService,
    http.Client? httpClient,
  }) : _appConfigService = appConfigService,
       _storageService = storageService,
       _httpClient = httpClient ?? http.Client();

  final AppConfigService _appConfigService;
  final StorageService _storageService;
  final http.Client _httpClient;
  int _requestSequence = 0;

  Future<Map<String, dynamic>> get(String path) async {
    final request = http.Request('GET', _buildUri(path));
    _attachHeaders(request);
    return _send(request);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final request = http.Request('POST', _buildUri(path));
    _attachHeaders(request);
    request.body = jsonEncode(body);
    return _send(request);
  }

  Uri _buildUri(String path) {
    final baseUrl = _appConfigService.config.value.baseUrl.replaceAll(
      RegExp(r'/$'),
      '',
    );
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath');
  }

  void _attachHeaders(http.Request request) {
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    final token = _storageService.token;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> _send(http.Request request) async {
    final config = _appConfigService.config.value;
    final requestId = ++_requestSequence;
    final stopwatch = Stopwatch()..start();
    try {
      AppLogger.apiRequest(
        requestId: requestId,
        method: request.method,
        url: request.url,
        headers: _maskHeaders(request.headers),
        body: request.body.isEmpty ? null : request.body,
      );
      final streamedResponse = await _httpClient
          .send(request)
          .timeout(Duration(seconds: config.receiveTimeoutSeconds));
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = response.body;
      stopwatch.stop();
      AppLogger.apiResponse(
        requestId: requestId,
        method: request.method,
        url: request.url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        headers: response.headers,
        body: responseBody,
      );
      final body = _decodeBody(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(
          body['message']?.toString() ??
              'Request failed with ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      return body;
    } on AppException {
      rethrow;
    } on TimeoutException catch (error, stackTrace) {
      stopwatch.stop();
      AppLogger.apiFailure(
        requestId: requestId,
        method: request.method,
        url: request.url,
        duration: stopwatch.elapsed,
        message: 'Request timed out.',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AppException('Request timed out. Please try again.');
    } on SocketException catch (error, stackTrace) {
      stopwatch.stop();
      AppLogger.apiFailure(
        requestId: requestId,
        method: request.method,
        url: request.url,
        duration: stopwatch.elapsed,
        message: 'Socket or connectivity error.',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AppException(
        'Unable to reach server. Please check your connection and try again.',
      );
    } on FormatException catch (error, stackTrace) {
      stopwatch.stop();
      AppLogger.apiFailure(
        requestId: requestId,
        method: request.method,
        url: request.url,
        duration: stopwatch.elapsed,
        message: 'Server returned invalid JSON.',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AppException(
        'Invalid server response received. Please try again.',
      );
    } on http.ClientException catch (error, stackTrace) {
      stopwatch.stop();
      AppLogger.apiFailure(
        requestId: requestId,
        method: request.method,
        url: request.url,
        duration: stopwatch.elapsed,
        message: 'HTTP client error.',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AppException(
        'Unable to reach server. Please check your connection and try again.',
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      AppLogger.apiFailure(
        requestId: requestId,
        method: request.method,
        url: request.url,
        duration: stopwatch.elapsed,
        message: 'Unexpected API error.',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    if (responseBody.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    throw const FormatException('Response body is not a JSON object.');
  }

  Map<String, String> _maskHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization' && value.isNotEmpty) {
        return MapEntry(key, _maskAuthorization(value));
      }
      return MapEntry(key, value);
    });
  }

  String _maskAuthorization(String value) {
    if (value.length <= 16) {
      return '***';
    }
    return '${value.substring(0, 12)}***${value.substring(value.length - 4)}';
  }
}
