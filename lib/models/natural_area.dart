class NaturalArea {
  final int id;
  final String name;
  final int? areaGroupId;
  final int? categoryNaturalAreaId;
  final int? departmentId;
  final int? daneCode;
  final double? landArea;
  final double? maritimeArea;
  
  // Propiedades calculadas para compatibilidad con las vistas
  String get description => 'Área Natural de Colombia'; // Valor por defecto
  String? get departmentName => null; // Se obtendría del objeto department si estuviera disponible
  String? get categoryNaturalArea => null; // Se obtendría del objeto category si estuviera disponible

  NaturalArea({
    required this.id,
    required this.name,
    this.areaGroupId,
    this.categoryNaturalAreaId,
    this.departmentId,
    this.daneCode,
    this.landArea,
    this.maritimeArea,
  });

  /// Crear instancia desde JSON
  factory NaturalArea.fromJson(Map<String, dynamic> json) {
    return NaturalArea(
      id: json['id'] as int,
      name: json['name'] as String,
      areaGroupId: json['areaGroupId'] as int?,
      categoryNaturalAreaId: json['categoryNaturalAreaId'] as int?,
      departmentId: json['departmentId'] as int?,
      daneCode: json['daneCode'] as int?,
      landArea: (json['landArea'] as num?)?.toDouble(),
      maritimeArea: (json['maritimeArea'] as num?)?.toDouble(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'areaGroupId': areaGroupId,
      'categoryNaturalAreaId': categoryNaturalAreaId,
      'departmentId': departmentId,
      'daneCode': daneCode,
      'landArea': landArea,
      'maritimeArea': maritimeArea,
    };
  }

  /// Crear copia con modificaciones
  NaturalArea copyWith({
    int? id,
    String? name,
    int? areaGroupId,
    int? categoryNaturalAreaId,
    int? departmentId,
    int? daneCode,
    double? landArea,
    double? maritimeArea,
  }) {
    return NaturalArea(
      id: id ?? this.id,
      name: name ?? this.name,
      areaGroupId: areaGroupId ?? this.areaGroupId,
      categoryNaturalAreaId: categoryNaturalAreaId ?? this.categoryNaturalAreaId,
      departmentId: departmentId ?? this.departmentId,
      daneCode: daneCode ?? this.daneCode,
      landArea: landArea ?? this.landArea,
      maritimeArea: maritimeArea ?? this.maritimeArea,
    );
  }

  @override
  String toString() {
    return 'NaturalArea(id: $id, name: $name, areaGroupId: $areaGroupId, departmentId: $departmentId, landArea: $landArea)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NaturalArea &&
        other.id == id &&
        other.name == name &&
        other.areaGroupId == areaGroupId &&
        other.departmentId == departmentId &&
        other.daneCode == daneCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      areaGroupId,
      departmentId,
      daneCode,
    );
  }
}