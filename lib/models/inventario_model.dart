class Proveedor {
  final String id;
  final String nombre;
  final String contacto;
  final String telefono;
  final String email;
  final String direccion;
  final bool activo;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.activo = true,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json, String docId) {
    return Proveedor(
      id: docId,
      nombre: json['nombre'] ?? '',
      contacto: json['contacto'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      direccion: json['direccion'] ?? '',
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'contacto': contacto,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'activo': activo,
      };
}

class Ingrediente {
  final String id;
  final String nombre;
  final String unidadMedida; // Ej: kg, litros, piezas
  final double stockActual;
  final double stockMinimo;
  final double costoUnitario;
  final bool activo;

  Ingrediente({
    required this.id,
    required this.nombre,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoUnitario,
    this.activo = true,
  });

  factory Ingrediente.fromJson(Map<String, dynamic> json, String docId) {
    return Ingrediente(
      id: docId,
      nombre: json['nombre'] ?? '',
      unidadMedida: json['unidad_medida'] ?? '',
      stockActual: (json['stock_actual'] as num?)?.toDouble() ?? 0.0,
      stockMinimo: (json['stock_minimo'] as num?)?.toDouble() ?? 0.0,
      costoUnitario: (json['costo_unitario'] as num?)?.toDouble() ?? 0.0,
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'unidad_medida': unidadMedida,
        'stock_actual': stockActual,
        'stock_minimo': stockMinimo,
        'costo_unitario': costoUnitario,
        'activo': activo,
      };
}
