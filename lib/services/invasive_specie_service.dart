import '../models/models.dart';
import '../config/config.dart';
import 'api_service_base.dart';

/// Servicio HTTP para gestionar Especies Invasoras de Colombia
/// 
/// Este servicio consume el endpoint /api/v1/InvasiveSpecie de la API Colombia
/// Proporciona métodos para obtener listas y elementos individuales de especies invasoras
class InvasiveSpecieService extends ApiServiceBase {
  
  /// URL completa para especies invasoras
  String get _endpoint => Config.invasiveSpecieEndpoint;

  /// Obtener todas las especies invasoras
  /// 
  /// Retorna una [ApiResponse] con una lista de [InvasiveSpecie]
  /// En caso de error, retorna la respuesta con el error correspondiente
  Future<ApiResponse<List<InvasiveSpecie>>> getAllInvasiveSpecies() async {
    try {
      final response = await getRequest(_endpoint);
      
      if (response.success && response.data != null) {
        return parseJsonList(response.data!, InvasiveSpecie.fromJson);
      }
      
      return ApiResponse.error(
        error: response.error ?? 'Error desconocido',
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error inesperado',
        message: 'Error al obtener especies invasoras: $e',
      );
    }
  }

  /// Obtener una especie invasora específica por ID
  /// 
  /// [id] - ID de la especie a buscar
  /// Retorna una [ApiResponse] con la [InvasiveSpecie] encontrada
  /// o un error si no existe o hay problemas de conexión
  Future<ApiResponse<InvasiveSpecie>> getInvasiveSpecieById(int id) async {
    try {
      final response = await getRequest('$_endpoint/$id');
      
      if (response.success && response.data != null) {
        return parseJsonObject(response.data!, InvasiveSpecie.fromJson);
      }
      
      return ApiResponse.error(
        error: response.error ?? 'Especie invasora no encontrada',
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error inesperado',
        message: 'Error al obtener especie invasora: $e',
      );
    }
  }

  /// Buscar especies invasoras por nombre
  /// 
  /// [query] - Término de búsqueda
  /// Retorna una lista filtrada de especies que coincidan con el término
  Future<ApiResponse<List<InvasiveSpecie>>> searchInvasiveSpecies(String query) async {
    try {
      final allSpeciesResponse = await getAllInvasiveSpecies();
      
      if (!allSpeciesResponse.success || allSpeciesResponse.data == null) {
        return allSpeciesResponse;
      }
      
      final filteredSpecies = allSpeciesResponse.data!
          .where((specie) =>
              specie.name.toLowerCase().contains(query.toLowerCase()) ||
              (specie.scientificName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (specie.riskLevel?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
      
      return ApiResponse.success(
        data: filteredSpecies,
        message: 'Encontradas ${filteredSpecies.length} especies',
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error en búsqueda',
        message: 'Error al buscar especies invasoras: $e',
      );
    }
  }

  /// Filtrar especies por nivel de riesgo
  /// 
  /// [riskLevel] - Nivel de riesgo a filtrar
  /// Retorna una lista de especies con el nivel de riesgo especificado
  Future<ApiResponse<List<InvasiveSpecie>>> getSpeciesByRiskLevel(String riskLevel) async {
    try {
      final allSpeciesResponse = await getAllInvasiveSpecies();
      
      if (!allSpeciesResponse.success || allSpeciesResponse.data == null) {
        return allSpeciesResponse;
      }
      
      final filteredSpecies = allSpeciesResponse.data!
          .where((specie) => 
              specie.riskLevel != null && 
              specie.riskLevel!.toLowerCase().contains(riskLevel.toLowerCase()))
          .toList();
      
      return ApiResponse.success(
        data: filteredSpecies,
        message: 'Encontradas ${filteredSpecies.length} especies con nivel de riesgo: $riskLevel',
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error al filtrar',
        message: 'Error al obtener especies por nivel de riesgo: $e',
      );
    }
  }

  /// Obtener especies invasoras paginadas
  /// 
  /// [page] - Número de página (empezando en 1)
  /// [pageSize] - Cantidad de elementos por página
  /// Retorna una [ApiResponse] con la lista paginada de [InvasiveSpecie]
  Future<ApiResponse<List<InvasiveSpecie>>> getInvasiveSpeciesPaginated({
    int page = 1, 
    int pageSize = 10
  }) async {
    try {
      final allSpeciesResponse = await getAllInvasiveSpecies();
      
      if (!allSpeciesResponse.success || allSpeciesResponse.data == null) {
        return allSpeciesResponse;
      }
      
      final allSpecies = allSpeciesResponse.data!;
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      
      if (startIndex >= allSpecies.length) {
        return ApiResponse.success(data: <InvasiveSpecie>[]);
      }
      
      final paginatedSpecies = allSpecies.sublist(
        startIndex,
        endIndex > allSpecies.length ? allSpecies.length : endIndex,
      );
      
      return ApiResponse.success(
        data: paginatedSpecies,
        message: 'Página $page de ${(allSpecies.length / pageSize).ceil()}',
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error en paginación',
        message: 'Error al obtener especies paginadas: $e',
      );
    }
  }

  /// Obtener niveles de riesgo únicos
  /// 
  /// Útil para filtros dinámicos en la UI
  /// Retorna una lista de strings con los niveles de riesgo disponibles
  Future<List<String>> getUniqueRiskLevels() async {
    try {
      final response = await getAllInvasiveSpecies();
      
      if (response.success && response.data != null) {
        final Set<String> riskLevels = <String>{};
        
        for (final specie in response.data!) {
          if (specie.riskLevel?.isNotEmpty == true) {
            riskLevels.add(specie.riskLevel!);
          }
        }
        
        final List<String> sortedRiskLevels = riskLevels.toList()..sort();
        return sortedRiskLevels;
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtener estadísticas básicas de las especies invasoras
  /// 
  /// Retorna información como total de especies, por nivel de riesgo, etc.
  Future<Map<String, dynamic>> getInvasiveSpecieStats() async {
    try {
      final response = await getAllInvasiveSpecies();
      
      if (response.success && response.data != null) {
        final species = response.data!;
        final riskLevels = <String, int>{};
        
        for (final specie in species) {
          final risk = specie.riskLevel ?? 'No especificado';
          riskLevels[risk] = (riskLevels[risk] ?? 0) + 1;
        }
        
        return {
          'total': species.length,
          'withImage': species.where((s) => s.hasImage).length,
          'withScientificName': species.where((s) => s.scientificName?.isNotEmpty == true).length,
          'riskLevelDistribution': riskLevels,
        };
      }
      
      return {
        'total': 0,
        'withImage': 0,
        'withScientificName': 0,
        'riskLevelDistribution': <String, int>{},
      };
    } catch (e) {
      return {
        'total': 0,
        'withImage': 0,
        'withScientificName': 0,
        'riskLevelDistribution': <String, int>{},
      };
    }
  }
}