import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sucursal {
  final String id;
  final String nombre;
  final String direccion;
  final String horario;
  final bool disponible;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horario,
    this.disponible = true,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json, String docId) {
    return Sucursal(
      id: docId,
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      horario: json['horario'] ?? '',
      disponible: json['disponible'] ?? true,
    );
  }
}

class SucursalesProvider extends ChangeNotifier {
  List<Sucursal> _sucursales = [];
  Sucursal? _sucursalSeleccionada;

  List<Sucursal> get sucursales => _sucursales;
  Sucursal? get sucursalSeleccionada => _sucursalSeleccionada;

  SucursalesProvider() {
    _escucharSucursales();
  }

  // 🔴 Escucha la base de datos en tiempo real
  void _escucharSucursales() {
    FirebaseFirestore.instance
        .collection('sucursal')
        .snapshots()
        .listen((snapshot) {
      _sucursales = snapshot.docs
          .map((doc) => Sucursal.fromJson(doc.data(), doc.id))
          .toList();

      // Si la sucursal seleccionada se borra o se cierra, la deseleccionamos
      if (_sucursalSeleccionada != null) {
        final existe = _sucursales
            .any((s) => s.id == _sucursalSeleccionada!.id && s.disponible);
        if (!existe) _sucursalSeleccionada = null;
      }

      notifyListeners();
    });
  }

  void seleccionarSucursal(Sucursal sucursal) {
    if (sucursal.disponible) {
      _sucursalSeleccionada = sucursal;
      notifyListeners();
    }
  }
}
