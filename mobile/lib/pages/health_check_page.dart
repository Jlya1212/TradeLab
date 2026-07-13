import 'package:flutter/material.dart';

import '../models/health_response.dart';
import '../services/health_api_service.dart';

class HealthCheckPage extends StatefulWidget {
  const HealthCheckPage({super.key, required this.healthApiService});

  final HealthApiService healthApiService;

  @override
  State<HealthCheckPage> createState() => _HealthCheckPageState();
}

class _HealthCheckPageState extends State<HealthCheckPage> {
  bool _isLoading = true;
  HealthResponse? _healthResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
      _healthResponse = null;
      _errorMessage = null;
    });

    try {
      final response = await widget.healthApiService.fetchHealth();
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _healthResponse = response;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TradeLab Connectivity')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildState(context),
          ),
        ),
      ),
    );
  }

  Widget _buildState(BuildContext context) {
    if (_isLoading) {
      return Semantics(
        liveRegion: true,
        label: 'Checking backend connection',
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Checking backend connection…'),
          ],
        ),
      );
    }

    final response = _healthResponse;
    if (response != null) {
      return Semantics(
        liveRegion: true,
        label: 'Backend connection successful',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Backend is reachable',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${response.service}\nStatus: ${response.status}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      label: 'Backend connection failed',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 20),
          Text(
            'Connection failed',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Unable to reach the backend.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _checkHealth,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
