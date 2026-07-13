class HealthResponse {
  const HealthResponse({required this.status, required this.service});

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final service = json['service'];

    if (json.length != 2 ||
        status is! String ||
        status.trim().isEmpty ||
        service is! String ||
        service.trim().isEmpty) {
      throw const FormatException('Invalid health response.');
    }

    return HealthResponse(status: status, service: service);
  }

  final String status;
  final String service;
}
