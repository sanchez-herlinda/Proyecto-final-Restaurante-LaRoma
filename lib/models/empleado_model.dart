class Empleado {
  final String id; // Este será el UID de Firebase Auth
  final String nombre;
  final String rol; // Ej: 'gerente', 'mesero', 'usuario'
  final String email;
  final bool activo;

  Empleado({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.email,
    this.activo = true,
  });

  factory Empleado.fromJson(Map<String, dynamic> json, String documentId) {
    return Empleado(
      id: documentId,
      nombre: json['nombre'] ?? '',
      rol: json['rol'] ?? 'usuario',
      email: json['email'] ?? '',
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'rol': rol,
      'email': email,
      'activo': activo,
    };
  }
}
