import '../models/models.dart';
import '../config/config.dart';
import 'api_service_base.dart';

/// Servicio HTTP para gestionar Regiones de Colombia
/// 
/// Este servicio consume el endpoint /api/v1/Region de la API Colombia
/// Proporciona métodos para obtener listas y elementos individuales de regiones
class RegionService extends ApiServiceBase {
  
  /// URL completa para regiones
  String get _endpoint => Config.regionEndpoint;

  /// Obtener todas las regiones
  /// 
  /// Retorna una [ApiResponse] con una lista de [Region]
  /// En caso de error, retorna la respuesta con el error correspondiente
  Future<ApiResponse<List<Region>>> getAllRegions() async {
    try {
      final response = await getRequest(_endpoint);
      
      if (response.success && response.data != null) {
        return parseJsonList(response.data!, Region.fromJson);
      }
      
      return ApiResponse.error(
        error: response.error ?? 'Error desconocido',
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error inesperado',
        message: 'Error al obtener regiones: $e',
      );
    }
  }

  /// Obtener una región específica por ID
  /// 
  /// [id] - ID de la región a buscar
  /// Retorna una [ApiResponse] con la [Region] encontrada
  /// o un error si no existe o hay problemas de conexión
  Future<ApiResponse<Region>> getRegionById(int id) async {
    try {
      final response = await getRequest('$_endpoint/$id');
      
      if (response.success && response.data != null) {
        return parseJsonObject(response.data!, Region.fromJson);
      }
      
      return ApiResponse.error(
        error: response.error ?? 'Región no encontrada',
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error inesperado',
        message: 'Error al obtener región: $e',
      );
    }
  }

  /// Buscar regiones por nombre
  /// 
  /// [query] - Término de búsqueda
  /// Retorna una lista filtrada de regiones que coincidan con el término
  Future<ApiResponse<List<Region>>> searchRegions(String query) async {
    try {
      final allRegionsResponse = await getAllRegions();
      
      if (!allRegionsResponse.success || allRegionsResponse.data == null) {
        return allRegionsResponse;
      }
      
      final filteredRegions = allRegionsResponse.data!
          .where((region) =>
              region.name.toLowerCase().contains(query.toLowerCase()) ||
              (region.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
      
      return ApiResponse.success(
        data: filteredRegions,
        message: 'Encontradas ${filteredRegions.length} regiones',
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error en búsqueda',
        message: 'Error al buscar regiones: $e',
      );
    }
  }

  /// Obtener regiones paginadas
  /// 
  /// [page] - Número de página (empezando en 1)
  /// [pageSize] - Cantidad de elementos por página
  /// Retorna una [ApiResponse] con la lista paginada de [Region]
  Future<ApiResponse<List<Region>>> getRegionsPaginated({
    int page = 1, 
    int pageSize = 10
  }) async {
    try {
      final allRegionsResponse = await getAllRegions();
      
      if (!allRegionsResponse.success || allRegionsResponse.data == null) {
        return allRegionsResponse;
      }
      
      final allRegions = allRegionsResponse.data!;
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      
      if (startIndex >= allRegions.length) {
        return ApiResponse.success(data: <Region>[]);
      }
      
      final paginatedRegions = allRegions.sublist(
        startIndex,
        endIndex > allRegions.length ? allRegions.length : endIndex,
      );
      
      return ApiResponse.success(
        data: paginatedRegions,
        message: 'Página $page de ${(allRegions.length / pageSize).ceil()}',
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error en paginación',
        message: 'Error al obtener regiones paginadas: $e',
      );
    }
  }



  /// Obtener estadísticas básicas de las regiones
  /// 
  /// Retorna información como total de regiones, etc.
  Future<Map<String, dynamic>> getRegionStats() async {
    try {
      final response = await getAllRegions();
      
      if (response.success && response.data != null) {
        final regions = response.data!;
        
        return {
          'total': regions.length,
          'withDescription': regions.where((r) => r.description?.isNotEmpty == true).length,
          'withoutDescription': regions.where((r) => r.description?.isEmpty != false).length,
        };
      }
      
      return {'total': 0, 'withDescription': 0, 'withoutDescription': 0};
    } catch (e) {
      return {'total': 0, 'withDescription': 0, 'withoutDescription': 0};
    }
  }
}