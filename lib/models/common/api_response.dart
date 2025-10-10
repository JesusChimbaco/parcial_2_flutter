/// Respuesta genérica de la API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  /// Constructor para respuesta exitosa
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  /// Constructor para respuesta de error
  factory ApiResponse.error({
    required String error,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message,
      statusCode: statusCode ?? 500,
    );
  }

  /// Crear desde JSON genérico
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    try {
      if (json['success'] == true || json['data'] != null) {
        return ApiResponse.success(
          data: fromJsonT(json['data'] ?? json),
          message: json['message'] as String?,
          statusCode: json['statusCode'] as int?,
        );
      } else {
        return ApiResponse.error(
          error: json['error'] as String? ?? 'Error desconocido',
          message: json['message'] as String?,
          statusCode: json['statusCode'] as int?,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al parsear la respuesta: $e',
        statusCode: 500,
      );
    }
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'error': error,
      'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, error: $error, statusCode: $statusCode)';
  }
}