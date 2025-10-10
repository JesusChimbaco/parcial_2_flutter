class InvasiveSpecie {
  final int id;
  final String name;
  final String? scientificName;
  final String? commonNames;
  final String? impact;
  final String? manage;
  final String? distribution;
  final String? riskLevel;
  final String? imageUrl;

  InvasiveSpecie({
    required this.id,
    required this.name,
    this.scientificName,
    this.commonNames,
    this.impact,
    this.manage,
    this.distribution,
    this.riskLevel,
    this.imageUrl,
  });

  /// Verificar si tiene imagen
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Obtener nivel de riesgo formateado
  String get formattedRiskLevel => riskLevel ?? 'No especificado';

  /// Crear instancia desde JSON
  factory InvasiveSpecie.fromJson(Map<String, dynamic> json) {
    try {
      // Manejar riskLevel como int o String
      String? riskLevel;
      if (json['riskLevel'] != null) {
        if (json['riskLevel'] is int) {
          // Convertir número a texto descriptivo
          switch (json['riskLevel'] as int) {
            case 1:
              riskLevel = 'Bajo';
              break;
            case 2:
              riskLevel = 'Medio';
              break;
            case 3:
              riskLevel = 'Alto';
              break;
            default:
              riskLevel = 'Nivel ${json['riskLevel']}';
          }
        } else if (json['riskLevel'] is String) {
          riskLevel = json['riskLevel'] as String?;
        }
      }

      return InvasiveSpecie(
        id: json['id'] as int,
        name: json['name'] as String,
        scientificName: json['scientificName'] as String?,
        commonNames: json['commonNames'] as String?,
        impact: json['impact'] as String?,
        manage: json['manage'] as String?,
        distribution: json['distribution'] as String?,
        riskLevel: riskLevel,
        imageUrl: json['urlImage'] as String?, // Nota: el campo se llama 'urlImage' en la API
      );
    } catch (e) {
      throw FormatException('Error parsing InvasiveSpecie JSON: $e');
    }
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'commonNames': commonNames,
      'impact': impact,
      'manage': manage,
      'distribution': distribution,
      'riskLevel': riskLevel,
      'urlImage': imageUrl,
    };
  }

  /// Crear copia con modificaciones
  InvasiveSpecie copyWith({
    int? id,
    String? name,
    String? scientificName,
    String? commonNames,
    String? impact,
    String? manage,
    String? distribution,
    String? riskLevel,
    String? imageUrl,
  }) {
    return InvasiveSpecie(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      commonNames: commonNames ?? this.commonNames,
      impact: impact ?? this.impact,
      manage: manage ?? this.manage,
      distribution: distribution ?? this.distribution,
      riskLevel: riskLevel ?? this.riskLevel,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'InvasiveSpecie(id: $id, name: $name, scientificName: $scientificName, riskLevel: $riskLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvasiveSpecie &&
        other.id == id &&
        other.name == name &&
        other.scientificName == scientificName &&
        other.riskLevel == riskLevel;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      scientificName,
      riskLevel,
    );
  }
}