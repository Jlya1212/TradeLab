import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/config/api_config.dart';
import 'package:mobile/services/health_api_service.dart';

void main() {
  test('ApiConfig uses the Android emulator development URL by default', () {
    expect(ApiConfig.baseUrl, 'http://10.0.2.2:8081');
  });

  group('HealthApiService', () {
    test('calls the health endpoint and parses a valid response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url, Uri.parse('http://10.0.2.2:8081/api/health'));
        expect(request.headers['Accept'], 'application/json');

        return http.Response(
          jsonEncode({'status': 'UP', 'service': 'TradeLab Backend'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final response = await HealthApiService(client: client).fetchHealth();

      expect(response.status, 'UP');
      expect(response.service, 'TradeLab Backend');
    });

    test('rejects a non-success HTTP status', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'status': 'DOWN'}),
          503,
          headers: {'content-type': 'application/json'},
        ),
      );

      await expectLater(
        HealthApiService(client: client).fetchHealth(),
        throwsA(
          isA<HealthApiException>().having(
            (error) => error.message,
            'message',
            contains('HTTP 503'),
          ),
        ),
      );
    });

    test('rejects a response that is not JSON', () async {
      final client = MockClient(
        (_) async => http.Response(
          '<html>Unavailable</html>',
          200,
          headers: {'content-type': 'text/html'},
        ),
      );

      await expectLater(
        HealthApiService(client: client).fetchHealth(),
        throwsA(
          isA<HealthApiException>().having(
            (error) => error.message,
            'message',
            contains('JSON response'),
          ),
        ),
      );
    });

    test('rejects JSON with an invalid health response shape', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'status': 'UP'}),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      await expectLater(
        HealthApiService(client: client).fetchHealth(),
        throwsA(
          isA<HealthApiException>().having(
            (error) => error.message,
            'message',
            contains('invalid health response'),
          ),
        ),
      );
    });
  });
}
