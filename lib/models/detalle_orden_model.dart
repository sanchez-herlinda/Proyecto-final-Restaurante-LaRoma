import 'platillo_model.dart';

class DetalleOrden {
  final String id;
  final Platillo platillo;
  int cantidad;
  final String notas; // Ej: "Sin cebolla"

  DetalleOrden({
    required this.id,
    required this.platillo,
    this.cantidad = 1,
    this.notas = '',
  });

  // Getter para calcular automáticamente el total por línea
  double get subtotal => platillo.precio * cantidad;

  factory DetalleOrden.fromJson(
      Map<String, dynamic> json, Platillo platillo, String documentId) {
    return DetalleOrden(
      id: documentId,
      platillo: platillo, // El platillo se inyecta desde el proveedor
      cantidad: json['cantidad'] ?? 1,
      notas: json['notas'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platillo_id': platillo.id,
      'cantidad': cantidad,
      'precio_unitario': platillo
          .precio, // Se guarda el precio histórico por si luego cambia en el menú
      'notas': notas,
    };
  }
}
