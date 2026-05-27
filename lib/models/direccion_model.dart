class Direccion {
  final String id;
  final String alias;
  final String calleYNumero;
  final String colonia;
  final String codigoPostal;
  final String indicaciones;

  Direccion({
    required this.id,
    required this.alias,
    required this.calleYNumero,
    required this.colonia,
    required this.codigoPostal,
    this.indicaciones = '',
  });

  factory Direccion.fromJson(Map<String, dynamic> json, String docId) {
    return Direccion(
      id: docId,
      alias: json['alias'] ?? '',
      calleYNumero: json['calle_y_numero'] ?? '',
      colonia: json['colonia'] ?? '',
      codigoPostal: json['codigo_postal'] ?? '',
      indicaciones: json['indicaciones'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'calle_y_numero': calleYNumero,
      'colonia': colonia,
      'codigo_postal': codigoPostal,
      'indicaciones': indicaciones,
    };
  }

  // 🔴 ESTO ARREGLA EL ERROR DEL DROPDOWN
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Direccion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          alias == other.alias;

  @override
  int get hashCode => id.hashCode ^ alias.hashCode;
}
