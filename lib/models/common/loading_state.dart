/// Estados de carga para la aplicación
enum LoadingState {
  /// Estado inicial o inactivo
  initial,
  
  /// Cargando datos
  loading,
  
  /// Datos cargados exitosamente
  loaded,
  
  /// Error al cargar los datos
  error,
  
  /// Sin datos disponibles
  empty,
}

/// Extensión para obtener información adicional del estado
extension LoadingStateExtension on LoadingState {
  /// Indica si está en estado de carga
  bool get isLoading => this == LoadingState.loading;
  
  /// Indica si los datos se cargaron correctamente
  bool get isLoaded => this == LoadingState.loaded;
  
  /// Indica si hay un error
  bool get hasError => this == LoadingState.error;
  
  /// Indica si no hay datos
  bool get isEmpty => this == LoadingState.empty;
  
  /// Indica si está en estado inicial
  bool get isInitial => this == LoadingState.initial;
}