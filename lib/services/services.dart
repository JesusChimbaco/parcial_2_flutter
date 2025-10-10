/// Servicios HTTP para la aplicación Datos Abiertos de Colombia
/// 
/// Este archivo exporta todos los servicios disponibles para facilitar las importaciones
/// 
/// Uso:
/// ```dart
/// import '../services/services.dart';
/// 
/// final dishService = TypicalDishService();
/// final areaService = NaturalAreaService();
/// ```

// Servicio base
export 'api_service_base.dart';

// Servicios específicos por endpoint
export 'typical_dish_service.dart';
export 'natural_area_service.dart';
export 'region_service.dart';
export 'invasive_specie_service.dart';