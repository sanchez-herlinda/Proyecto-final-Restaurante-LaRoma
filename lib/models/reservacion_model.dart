import 'package:cloud_firestore/cloud_firestore.dart';

class Mesa {
  final String id;
  final String sucursalId; // Conexión con Sucursales
  final String numero;
  final int capacidad;
  final String ubicacion; // Ej: Ventana, Terraza, Centro
  final String estado; // libre, ocupada, reservada

  Mesa({
    required this.id,
    required this.sucursalId,
    required this.numero,
    required this.capacidad,
    required this.ubicacion,
    required this.estado,
  });

  factory Mesa.fromJson(Map<String, dynamic> json, String docId) {
    return Mesa(
      id: docId,
      sucursalId: json['sucursal_id'] ?? '',
      numero: json['numero'] ?? '',
      capacidad: json['capacidad'] ?? 2,
      ubicacion: json['ubicacion'] ?? '',
      estado: json['estado'] ?? 'libre',
    );
  }

  Map<String, dynamic> toJson() => {
        'sucursal_id': sucursalId,
        'numero': numero,
        'capacidad': capacidad,
        'ubicacion': ubicacion,
        'estado': estado,
      };
}

class Reservacion {
  final String id;
  final String clienteId;
  final String sucursalId;
  final String mesaId;
  final DateTime fechaHora;
  final int numPersonas;
  final String estado; // pendiente, confirmada, cancelada
  final String notas;

  Reservacion({
    required this.id,
    required this.clienteId,
    required this.sucursalId,
    required this.mesaId,
    required this.fechaHora,
    required this.numPersonas,
    required this.estado,
    required this.notas,
  });

  factory Reservacion.fromJson(Map<String, dynamic> json, String docId) {
    return Reservacion(
      id: docId,
      clienteId: json['cliente_id'] ?? '',
      sucursalId: json['sucursal_id'] ?? '',
      mesaId: json['mesa_id'] ?? '',
      fechaHora: (json['fecha_hora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      numPersonas: json['num_personas'] ?? 1,
      estado: json['estado'] ?? 'pendiente',
      notas: json['notas'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cliente_id': clienteId,
        'sucursal_id': sucursalId,
        'mesa_id': mesaId,
        'fecha_hora': Timestamp.fromDate(fechaHora),
        'num_personas': numPersonas,
        'estado': estado,
        'notas': notas,
      };
}
