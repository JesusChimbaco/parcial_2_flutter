import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/models.dart';

/// Clase base para todos los servicios HTTP
/// Contiene la lógica común para hacer peticiones a la API de Colombia
abstract class ApiServiceBase {
  // Cliente HTTP reutilizable
  final http.Client _client = http.Client();
  
  // Timeout por defecto para las peticiones
  static const Duration _defaultTimeout = Duration(seconds: 30);

  /// Headers comunes para todas las peticiones
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-App-DatosAbiertos/1.0',
  };

  /// Realizar petición GET genérica
  /// 
  /// [endpoint] - Endpoint específico (ej: '/TypicalDish')
  /// [queryParams] - Parámetros de consulta opcionales
  /// 
  /// Retorna: [ApiResponse<String>] con el JSON crudo o error
  Future<ApiResponse<String>> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      // Construir la URL completa
      final uri = _buildUri(endpoint, queryParams);
      
      if (Config.isDevelopment) {
        print('🌐 GET Request: $uri');
      }

      // Realizar la petición HTTP
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_defaultTimeout);

      if (Config.isDevelopment) {
        print('📡 Response Status: ${response.statusCode}');
      }

      // Verificar si la respuesta fue exitosa
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: response.body,
          statusCode: response.statusCode,
        );
      } else {
        return _handleHttpError(response);
      }
    } on SocketException catch (e) {
      return ApiResponse.error(
        error: 'Sin conexión a internet',
        message: 'Verifica tu conexión: ${e.message}',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        error: 'Error de cliente HTTP',
        message: e.message,
        statusCode: 0,
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        error: 'Formato de respuesta inválido',
        message: 'La respuesta no es JSON válido: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error inesperado',
        message: e.toString(),
        statusCode: 0,
      );
    }
  }

  /// Parsear respuesta JSON a lista de objetos
  /// 
  /// [jsonResponse] - JSON como string
  /// [fromJson] - Función para convertir Map a objeto T
  /// 
  /// Retorna: [ApiResponse<List<T>>]
  ApiResponse<List<T>> parseJsonList<T>(
    String jsonResponse,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final dynamic decoded = json.decode(jsonResponse);
      
      List<T> items = [];
      List<String> parseErrors = [];
      
      if (decoded is List) {
        // Si la respuesta es directamente una lista
        for (int i = 0; i < decoded.length; i++) {
          try {
            final item = decoded[i];
            if (item is Map<String, dynamic>) {
              items.add(fromJson(item));
            } else {
              parseErrors.add('Item $i: Tipo inesperado ${item.runtimeType}');
            }
          } catch (e) {
            parseErrors.add('Item $i: Error de parsing - $e');
            if (Config.isDevelopment) {
              print('❌ Error parseando item $i: $e');
              print('📄 Datos del item: ${decoded[i]}');
            }
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        // Si la respuesta está encapsulada en un objeto
        if (decoded.containsKey('data') && decoded['data'] is List) {
          final dataList = decoded['data'] as List;
          for (int i = 0; i < dataList.length; i++) {
            try {
              final item = dataList[i];
              if (item is Map<String, dynamic>) {
                items.add(fromJson(item));
              } else {
                parseErrors.add('Item $i: Tipo inesperado ${item.runtimeType}');
              }
            } catch (e) {
              parseErrors.add('Item $i: Error de parsing - $e');
            }
          }
        } else {
          // Si es un solo objeto, convertirlo a lista
          try {
            items = [fromJson(decoded)];
          } catch (e) {
            parseErrors.add('Objeto único: Error de parsing - $e');
          }
        }
      }

      if (items.isEmpty && parseErrors.isNotEmpty) {
        return ApiResponse.error(
          error: 'Error al parsear JSON',
          message: 'No se pudo parsear ningún elemento. Errores: ${parseErrors.join(', ')}',
        );
      }

      if (parseErrors.isNotEmpty && Config.isDevelopment) {
        print('⚠️ Algunos elementos no se pudieron parsear: ${parseErrors.length} errores');
      }

      return ApiResponse.success(data: items);
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al parsear JSON',
        message: 'No se pudo convertir la respuesta: $e',
      );
    }
  }

  /// Parsear respuesta JSON a un objeto individual
  /// 
  /// [jsonResponse] - JSON como string  
  /// [fromJson] - Función para convertir Map a objeto T
  /// 
  /// Retorna: [ApiResponse<T>]
  ApiResponse<T> parseJsonObject<T>(
    String jsonResponse,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final dynamic decoded = json.decode(jsonResponse);
      
      if (decoded is Map<String, dynamic>) {
        final object = fromJson(decoded);
        return ApiResponse.success(data: object);
      } else {
        return ApiResponse.error(
          error: 'Formato inesperado',
          message: 'Se esperaba un objeto, pero se recibió: ${decoded.runtimeType}',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al parsear objeto',
        message: 'No se pudo convertir la respuesta: $e',
      );
    }
  }

  /// Construir URI completa con parámetros
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    // Si el endpoint es una URL completa, usarla directamente
    String fullUrl;
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      fullUrl = endpoint;
    } else {
      // Si es un endpoint relativo, construir URL con la base
      final baseUrl = Config.apiBaseUrl;
      fullUrl = '$baseUrl$endpoint';
    }
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(fullUrl).replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    
    return Uri.parse(fullUrl);
  }

  /// Manejo de errores HTTP específicos
  ApiResponse<String> _handleHttpError(http.Response response) {
    String errorMessage;
    
    switch (response.statusCode) {
      case 400:
        errorMessage = 'Solicitud incorrecta';
        break;
      case 401:
        errorMessage = 'No autorizado';
        break;
      case 403:
        errorMessage = 'Acceso denegado';
        break;
      case 404:
        errorMessage = 'Recurso no encontrado';
        break;
      case 500:
        errorMessage = 'Error interno del servidor';
        break;
      case 502:
        errorMessage = 'Puerta de enlace incorrecta';
        break;
      case 503:
        errorMessage = 'Servicio no disponible';
        break;
      default:
        errorMessage = 'Error HTTP ${response.statusCode}';
    }

    return ApiResponse.error(
      error: errorMessage,
      message: 'Respuesta del servidor: ${response.body}',
      statusCode: response.statusCode,
    );
  }

  /// Limpiar recursos al finalizar
  void dispose() {
    _client.close();
  }
}