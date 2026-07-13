import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/health_response.dart';

class HealthApiException implements Exception {
  const HealthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HealthApiService {
  HealthApiService({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 5),
  }) : _client = client;

  final http.Client? _client;
  final Duration requestTimeout;

  Future<HealthResponse> fetchHealth() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/health');
    final client = _client ?? http.Client();

    try {
      final response = await client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw HealthApiException(
          'Backend returned HTTP ${response.statusCode}.',
        );
      }

      final contentType = response.headers['content-type'];
      if (contentType == null ||
          !contentType.toLowerCase().startsWith('application/json')) {
        throw const HealthApiException(
          'Backend did not return a JSON response.',
        );
      }

      return _decodeResponse(response.body);
    } on TimeoutException {
      throw const HealthApiException('The health request timed out.');
    } on http.ClientException catch (error) {
      throw HealthApiException('Unable to reach the backend: ${error.message}');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  HealthResponse _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }

      return HealthResponse.fromJson(decoded);
    } on FormatException {
      throw const HealthApiException(
        'Backend returned an invalid health response.',
      );
    }
  }
}
