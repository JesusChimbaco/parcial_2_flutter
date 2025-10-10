class TypicalDish {
  final int id;
  final String name;
  final String description;
  final String ingredients; // La API devuelve ingredients como string, no array
  final String? imageUrl;
  final int? departmentId;
  final Map<String, dynamic>? department; // Objeto completo del departamento

  TypicalDish({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    this.imageUrl,
    this.departmentId,
    this.department,
  });

  /// Obtener nombre del departamento desde el objeto department
  String? get departmentName => department?['name'] as String?;
  
  /// Convertir ingredients string a lista (para compatibilidad con vistas)
  List<String> get ingredientsList {
    return ingredients.split(',').map((e) => e.trim()).toList();
  }

  /// Crear instancia desde JSON
  factory TypicalDish.fromJson(Map<String, dynamic> json) {
    return TypicalDish(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: json['ingredients'] as String,
      imageUrl: json['imageUrl'] as String?,
      departmentId: json['departmentId'] as int?,
      department: json['department'] as Map<String, dynamic>?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'departmentId': departmentId,
      'department': department,
    };
  }

  /// Crear copia con modificaciones
  TypicalDish copyWith({
    int? id,
    String? name,
    String? description,
    String? ingredients,
    String? imageUrl,
    int? departmentId,
    Map<String, dynamic>? department,
  }) {
    return TypicalDish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      imageUrl: imageUrl ?? this.imageUrl,
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
    );
  }

  @override
  String toString() {
    return 'TypicalDish(id: $id, name: $name, description: $description, department: ${departmentName ?? "N/A"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypicalDish &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.ingredients == ingredients &&
        other.departmentId == departmentId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      ingredients,
      departmentId,
    );
  }
}