import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/direccion_model.dart';
import '../models/tarjeta_model.dart';

class PerfilProvider extends ChangeNotifier {
  List<Direccion> _direcciones = [];
  List<TarjetaBancaria> _tarjetas = [];

  List<Direccion> get direcciones => _direcciones;
  List<TarjetaBancaria> get tarjetas => _tarjetas;

  // Controladores para escuchar la base de datos en tiempo real
  StreamSubscription? _direccionesSub;
  StreamSubscription? _tarjetasSub;

  // 🔴 ESTA FUNCIÓN SE LLAMA DESDE EL LOGIN
  void cargarPerfil(String userId) {
    // 1. Limpiamos escuchas anteriores por si otro usuario cerró sesión
    limpiarPerfil();

    // 2. Escuchar Direcciones en TIEMPO REAL
    _direccionesSub = FirebaseFirestore.instance
        .collection('empleado') // La colección donde guardas a los usuarios
        .doc(userId)
        .collection('direcciones')
        .snapshots()
        .listen((snapshot) {
      _direcciones = snapshot.docs
          .map((doc) => Direccion.fromJson(doc.data(), doc.id))
          .toList();
      notifyListeners(); // 🔴 Esto le avisa a la pantalla que debe repintarse
    });

    // 3. Escuchar Tarjetas en TIEMPO REAL
    _tarjetasSub = FirebaseFirestore.instance
        .collection('empleado')
        .doc(userId)
        .collection('tarjetas')
        .snapshots()
        .listen((snapshot) {
      _tarjetas = snapshot.docs
          .map((doc) => TarjetaBancaria.fromJson(doc.data(), doc.id))
          .toList();
      notifyListeners(); // 🔴 Esto le avisa a la pantalla que debe repintarse
    });
  }

  Future<void> agregarDireccion(String userId, Direccion direccion) async {
    await FirebaseFirestore.instance
        .collection('empleado')
        .doc(userId)
        .collection('direcciones')
        .add(direccion.toJson());
    // Ya no hace falta actualizar la lista manualmente porque el '.listen()' de arriba lo detecta solo.
  }

  Future<void> agregarTarjeta(String userId, TarjetaBancaria tarjeta) async {
    await FirebaseFirestore.instance
        .collection('empleado')
        .doc(userId)
        .collection('tarjetas')
        .add(tarjeta.toJson());
    // Igual aquí, la magia de Firebase en tiempo real hace el trabajo.
  }
  // 🔴 NUEVAS FUNCIONES PARA ACTUALIZAR Y ELIMINAR

  Future<void> actualizarDireccion(
      String userId, String direccionId, Direccion direccionActualizada) async {
    await FirebaseFirestore.instance
        .collection('empleado')
        .doc(userId)
        .collection('direcciones')
        .doc(direccionId) // Apuntamos al documento exacto
        .update(direccionActualizada.toJson());
  }

  Future<void> eliminarDireccion(String userId, String direccionId) async {
    await FirebaseFirestore.instance
        .collection('empleado')
        .doc(userId)
        .collection('direcciones')
        .doc(direccionId)
        .delete();
  }

  Future<void> eliminarTarjeta(String userId, String tarjetaId) async {
    await FirebaseFirestore.instance
        .collection('empleado')
        .doc(userId)
        .collection('tarjetas')
        .doc(tarjetaId)
        .delete();
  }

  // 🔴 ESTA FUNCIÓN SE DEBE LLAMAR AL CERRAR SESIÓN (Logout)
  void limpiarPerfil() {
    _direccionesSub?.cancel();
    _tarjetasSub?.cancel();
    _direcciones = [];
    _tarjetas = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _direccionesSub?.cancel();
    _tarjetasSub?.cancel();
    super.dispose();
  }
}
