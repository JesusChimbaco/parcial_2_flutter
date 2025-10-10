import '../models/models.dart';
import '../config/config.dart';
import 'api_service_base.dart';

/// Servicio HTTP para gestionar Áreas Naturales de Colombia
/// 
/// Este servicio consume el endpoint /api/v1/NaturalArea de la API Colombia
/// Proporciona métodos para obtener listas y elementos individuales de áreas naturales
class NaturalAreaService extends ApiServiceBase {
  
  /// URL completa para áreas naturales
  String get _endpoint => Config.naturalAreaEndpoint;

  /// Obtener todas las áreas naturales
  /// 
  /// Retorna: [ApiResponse<List<NaturalArea>>] con la lista de áreas o error
  Future<ApiResponse<List<NaturalArea>>> getAllNaturalAreas() async {
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

      // Parsear JSON a lista de objetos NaturalArea
      return parseJsonList<NaturalArea>(
        response.data!,
        NaturalArea.fromJson,
      );
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al obtener áreas naturales',
        message: e.toString(),
      );
    }
  }

  /// Obtener un área natural específica por ID
  /// 
  /// [id] - ID único del área natural
  /// 
  /// Retorna: [ApiResponse<NaturalArea>] con el área específica o error
  Future<ApiResponse<NaturalArea>> getNaturalAreaById(int id) async {
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

      // Parsear JSON a objeto NaturalArea
      return parseJsonObject<NaturalArea>(
        response.data!,
        NaturalArea.fromJson,
      );
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al obtener área natural',
        message: e.toString(),
      );
    }
  }

  /// Buscar áreas naturales por nombre
  /// 
  /// [query] - Término de búsqueda
  Future<ApiResponse<List<NaturalArea>>> searchNaturalAreasByName(String query) async {
    try {
      final response = await getAllNaturalAreas();
      
      if (!response.success) {
        return response;
      }

      final filteredAreas = response.data!
          .where((area) =>
              area.name.toLowerCase().contains(query.toLowerCase()) ||
              area.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return ApiResponse.success(data: filteredAreas);
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error en la búsqueda',
        message: e.toString(),
      );
    }
  }

  /// Obtener áreas naturales por departamento
  /// 
  /// [departmentName] - Nombre del departamento
  Future<ApiResponse<List<NaturalArea>>> getNaturalAreasByDepartment(String departmentName) async {
    try {
      final response = await getAllNaturalAreas();
      
      if (!response.success) {
        return response;
      }

      final departmentAreas = response.data!
          .where((area) => 
              area.departmentName != null && 
              area.departmentName!.toLowerCase().contains(departmentName.toLowerCase()))
          .toList();

      return ApiResponse.success(data: departmentAreas);
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al filtrar por departamento',
        message: e.toString(),
      );
    }
  }

  /// Obtener áreas naturales por tipo de grupo
  /// 
  /// [areaGroupName] - Tipo de área (Parque Nacional, Reserva, etc.)
  Future<ApiResponse<List<NaturalArea>>> getNaturalAreasByGroup(String areaGroupName) async {
    try {
      final response = await getAllNaturalAreas();
      
      if (!response.success) {
        return response;
      }

      final groupAreas = response.data!
          .where((area) => 
              area.categoryNaturalArea != null &&
              area.categoryNaturalArea!.toLowerCase().contains(areaGroupName.toLowerCase()))
          .toList();

      return ApiResponse.success(data: groupAreas);
      
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al filtrar por grupo',
        message: e.toString(),
      );
    }
  }
}