class Region {
  final int id;
  final String name;
  final String? description;

  Region({
    required this.id,
    required this.name,
    this.description,
  });

  /// Crear instancia desde JSON
  factory Region.fromJson(Map<String, dynamic> json) {
    try {
      return Region(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
    } catch (e) {
      throw FormatException('Error parsing Region JSON: $e');
    }
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  /// Crear copia con modificaciones
  Region copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Region(id: $id, name: $name, description: ${description?.substring(0, description!.length > 50 ? 50 : description!.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Region &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
    );
  }
}