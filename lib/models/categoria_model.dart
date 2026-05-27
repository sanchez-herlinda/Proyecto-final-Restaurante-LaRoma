class Categoria {
  final String id;
  final String nombre;
  final String descripcion;
  final bool activa;

  Categoria({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.activa = true,
  });

  // Convierte el JSON de Firestore a un objeto Dart
  factory Categoria.fromJson(Map<String, dynamic> json, String documentId) {
    return Categoria(
      id: documentId,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      activa: json['activa'] ?? true,
    );
  }

  // Convierte el objeto Dart a JSON para subir a Firestore
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'activa': activa,
    };
  }
}
