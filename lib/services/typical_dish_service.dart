import '../models/models.dart';
import '../config/config.dart';
import 'api_service_base.dart';

/// Servicio HTTP para gestionar Platos Típicos de Colombia
/// 
/// Este servicio consume el endpoint /api/v1/TypicalDish de la API Colombia
/// Proporciona métodos para obtener listas y elementos individuales
class TypicalDishService extends ApiServiceBase {
  
  /// URL completa para platos típicos
  String get _endpoint => Config.typicalDishEndpoint;

  /// Obtener todos los platos típicos
  /// 
  /// Retorna: [ApiResponse<List<TypicalDish>>] con la lista de platos o error
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final service = TypicalDishService();
  /// final response = await service.getAllTypicalDishes();
  /// 
  /// if (response.success) {
  ///   final dishes = response.data!;
  ///   print('Encontrados ${dishes.length} platos');
  /// } else {
  ///   print('Error: ${response.error}');
  /// }
  /// ```
  Future<ApiResponse<List<TypicalDish>>> getAllTypicalDishes() async {
    try {
      // Hacer petición HTTP al endpoint
      final response = await getRequest(_endpoint);
      
      // Verificar si la petición fue exitosa
      if (!response.success) {
        return ApiResponse.error(
          error: response.error!,
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      // Parsear JSON a lista de objetos TypicalDish
      return parseJsonList<TypicalDish>(
        response.data!,
        TypicalDish.fromJson,
      );
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al obtener platos típicos',
        message: e.toString(),
      );
    }
  }

  /// Obtener un plato típico específico por ID
  /// 
  /// [id] - ID único del plato típico
  /// 
  /// Retorna: [ApiResponse<TypicalDish>] con el plato específico o error
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final service = TypicalDishService();
  /// final response = await service.getTypicalDishById(1);
  /// 
  /// if (response.success) {
  ///   final dish = response.data!;
  ///   print('Plato: ${dish.name}');
  ///   print('Descripción: ${dish.description}');
  /// } else {
  ///   print('Plato no encontrado: ${response.error}');
  /// }
  /// ```
  Future<ApiResponse<TypicalDish>> getTypicalDishById(int id) async {
    try {
      // Construir endpoint con ID específico
      final endpoint = '$_endpoint/$id';
      
      // Hacer petición HTTP
      final response = await getRequest(endpoint);
      
      // Verificar si la petición fue exitosa
      if (!response.success) {
        return ApiResponse.error(
          error: response.error!,
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      // Parsear JSON a objeto TypicalDish
      return parseJsonObject<TypicalDish>(
        response.data!,
        TypicalDish.fromJson,
      );
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al obtener plato típico',
        message: e.toString(),
      );
    }
  }

  /// Buscar platos típicos por nombre (búsqueda local)
  /// 
  /// [query] - Término de búsqueda
  /// 
  /// Retorna: [ApiResponse<List<TypicalDish>>] con platos filtrados
  /// 
  /// Nota: Este método primero obtiene todos los platos y luego filtra localmente
  /// En un escenario real, preferirías un endpoint de búsqueda en el servidor
  Future<ApiResponse<List<TypicalDish>>> searchTypicalDishesByName(String query) async {
    try {
      // Obtener todos los platos
      final response = await getAllTypicalDishes();
      
      if (!response.success) {
        return response;
      }

      // Filtrar platos que contengan el término de búsqueda
      final filteredDishes = response.data!
          .where((dish) =>
              dish.name.toLowerCase().contains(query.toLowerCase()) ||
              dish.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return ApiResponse.success(data: filteredDishes);
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error en la búsqueda',
        message: e.toString(),
      );
    }
  }

  /// Obtener platos típicos por región
  /// 
  /// [region] - Nombre de la región
  /// 
  /// Retorna: [ApiResponse<List<TypicalDish>>] con platos de la región
  Future<ApiResponse<List<TypicalDish>>> getTypicalDishesByRegion(String region) async {
    try {
      // Obtener todos los platos
      final response = await getAllTypicalDishes();
      
      if (!response.success) {
        return response;
      }

      // Filtrar por región
      final regionalDishes = response.data!
          .where((dish) => 
              dish.departmentName != null &&
              dish.departmentName!.toLowerCase().contains(region.toLowerCase()))
          .toList();

      return ApiResponse.success(data: regionalDishes);
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al filtrar por región',
        message: e.toString(),
      );
    }
  }
}