import 'package:flutter/material.dart';

import 'pages/health_check_page.dart';
import 'services/health_api_service.dart';

void main() {
  runApp(MyApp(healthApiService: HealthApiService()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.healthApiService});

  final HealthApiService healthApiService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HealthCheckPage(healthApiService: healthApiService),
    );
  }
}
