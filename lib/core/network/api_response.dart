/// Mirrors the backend response envelope exactly
/// (`api/internal/shared/response/response.go`):
/// `{success, status_code, timestamp, request_id, message, data}`.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.timestamp,
    required this.requestId,
    required this.message,
    required this.data,
  });

  final bool success;
  final int statusCode;
  final DateTime timestamp;
  final String requestId;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromData,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      requestId: json['request_id'] as String,
      message: json['message'] as String? ?? '',
      data: rawData == null ? null : fromData(rawData),
    );
  }
}
