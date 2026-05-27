class TarjetaBancaria {
  final String id;
  final String nombreTitular;
  final String numeroOculto;
  final String numeroCompleto;
  final String fechaVencimiento;
  final String cvc; // 🔴 NUEVO CAMPO
  final String tipo;

  TarjetaBancaria({
    required this.id,
    required this.nombreTitular,
    required this.numeroOculto,
    required this.numeroCompleto,
    required this.fechaVencimiento,
    required this.cvc,
    required this.tipo,
  });

  factory TarjetaBancaria.fromJson(Map<String, dynamic> json, String docId) {
    return TarjetaBancaria(
      id: docId,
      nombreTitular: json['nombre_titular'] ?? '',
      numeroOculto: json['numero_oculto'] ?? '',
      numeroCompleto: json['numero_completo'] ?? '',
      fechaVencimiento: json['fecha_vencimiento'] ?? '',
      cvc: json['cvc'] ?? '',
      tipo: json['tipo'] ?? 'Visa',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_titular': nombreTitular,
      'numero_oculto': numeroOculto,
      'numero_completo': numeroCompleto,
      'fecha_vencimiento': fechaVencimiento,
      'cvc': cvc,
      'tipo': tipo,
    };
  }

  // 🔴 ESTO ARREGLA EL ERROR DEL DROPDOWN
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarjetaBancaria &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          numeroCompleto == other.numeroCompleto;

  @override
  int get hashCode => id.hashCode ^ numeroCompleto.hashCode;
}
