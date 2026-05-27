import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/platillo_model.dart';
import '../models/detalle_orden_model.dart';

class CarritoProvider extends ChangeNotifier {
  final List<DetalleOrden> _items = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<DetalleOrden> get items => _items;

  // Calcular el total
  double get total =>
      _items.fold(0, (acumulador, item) => acumulador + item.subtotal);

  void agregarPlatillo(Platillo platillo, {int cantidad = 1}) {
    int index = _items.indexWhere((item) => item.platillo.id == platillo.id);
    if (index != -1) {
      _items[index].cantidad += cantidad;
    } else {
      _items.add(DetalleOrden(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        platillo: platillo,
        cantidad: cantidad,
      ));
    }
    notifyListeners();
  }

  void removerPlatillo(String platilloId) {
    int index = _items.indexWhere((item) => item.platillo.id == platilloId);
    if (index != -1) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void eliminarFilaCompleta(String platilloId) {
    _items.removeWhere((item) => item.platillo.id == platilloId);
    notifyListeners();
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }

  // 🔴 NUEVO MÉTODO: Guarda la orden en Firebase
  // Reemplaza esta parte dentro del archivo `lib/providers/carrito_provider.dart`
  Future<void> procesarPago(String clienteId) async {
    if (_items.isEmpty) return;

    final batch = _db.batch();
    final ordenRef = _db.collection('orden').doc();

    // Sumamos el costo de envío al total
    double costoEnvio = 35.0;
    double totalConEnvio = total + costoEnvio;

    // 🔴 AQUÍ GUARDAMOS EL ARREGLO DE ITEMS PARA EL HISTORIAL RÁPIDO
    batch.set(ordenRef, {
      'id': ordenRef.id,
      'cliente_id': clienteId,
      'empleado_id': 'app_movil',
      'mesa_id': 'para_llevar',
      'fecha_hora': FieldValue.serverTimestamp(),
      'estado': 'pendiente',
      'subtotal': total,
      'impuesto': 0,
      'total': totalConEnvio, // Total real pagado
      // ESTE ES EL CAMBIO CLAVE:
      'items': _items
          .map((item) => {
                'nombre_platillo': item.platillo.nombre,
                'cantidad': item.cantidad,
                'subtotal': item.subtotal,
              })
          .toList(),
    });

    // Mantenemos tu subcolección para la cocina/admin
    for (var item in _items) {
      final detalleRef = ordenRef.collection('detalle_orden').doc();
      batch.set(detalleRef, {
        'id': detalleRef.id,
        'orden_id': ordenRef.id,
        'platillo_id': item.platillo.id,
        'nombre_platillo': item.platillo.nombre,
        'cantidad': item.cantidad,
        'precio_unitario': item.platillo.precio,
        'notas': item.notas,
      });
    }

    final pagoRef = _db.collection('pago').doc();
    batch.set(pagoRef, {
      'id': pagoRef.id,
      'orden_id': ordenRef.id,
      'metodo_pago': 'tarjeta',
      'monto': totalConEnvio, // Se cobra el total con envío
      'referencia':
          'APP-${DateTime.now().millisecondsSinceEpoch}', // Referencia dinámica
      'fecha_hora': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    limpiarCarrito(); // No olvides limpiar el carrito después de pagar!
  }
}
