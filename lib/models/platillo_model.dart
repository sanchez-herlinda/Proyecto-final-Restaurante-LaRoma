class Platillo {
  final String id;
  final String categoriaId;
  final String nombre;
  final String descripcion;
  final double precio;
  final bool disponible;
  final String imagenUrl;

  Platillo({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.disponible = true,
    required this.imagenUrl,
  });

  factory Platillo.fromJson(Map<String, dynamic> json, String docId) {
    String urlOriginal = json['imagenUrl'] ?? '';

    // 🔴 Truco de seguridad: Si la URL trae un doble "main//", lo repara a "main/" automáticamente
    String urlSanitizada = urlOriginal.replaceAll('main//', 'main/');

    return Platillo(
      id: docId,
      categoriaId: json['categoriaId'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      imagenUrl: urlSanitizada, // Asignamos la URL limpia
      disponible: json['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'disponible': disponible,
      'imagen_url': imagenUrl,
    };
  }
}
