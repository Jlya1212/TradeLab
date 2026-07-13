import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/pages/health_check_page.dart';
import 'package:mobile/services/health_api_service.dart';

void main() {
  testWidgets('shows loading and then success', (tester) async {
    final response = Completer<http.Response>();
    final client = MockClient((_) => response.future);

    await tester.pumpWidget(
      MaterialApp(
        home: HealthCheckPage(
          healthApiService: HealthApiService(client: client),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Checking backend connection…'), findsOneWidget);

    response.complete(
      http.Response(
        jsonEncode({'status': 'UP', 'service': 'TradeLab Backend'}),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backend is reachable'), findsOneWidget);
    expect(find.text('TradeLab Backend\nStatus: UP'), findsOneWidget);
  });

  testWidgets('shows an error and retries the request', (tester) async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      if (requestCount == 1) {
        return http.Response(
          jsonEncode({'message': 'Unavailable'}),
          503,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response(
        jsonEncode({'status': 'UP', 'service': 'TradeLab Backend'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HealthCheckPage(
          healthApiService: HealthApiService(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connection failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(requestCount, 2);
    expect(find.text('Backend is reachable'), findsOneWidget);
  });
}
