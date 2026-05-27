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
  Future<void> procesarPago(String clienteId) async {
    if (_items.isEmpty) return;

    // Usamos batch para que si falla algo, no se guarde nada a medias
    final batch = _db.batch();

    // 1. Crear el documento de la Orden Principal
    final ordenRef = _db.collection('orden').doc();
    batch.set(ordenRef, {
      'id': ordenRef.id,
      'cliente_id': clienteId,
      'empleado_id': 'app_movil', // Identificador de origen
      'mesa_id': 'para_llevar',
      'fecha_hora': FieldValue.serverTimestamp(),
      'estado': 'pendiente', // Listo para que la cocina lo vea
      'subtotal': total,
      'impuesto': 0,
      'total': total,
    });

    // 2. Crear los Detalles de la Orden como subcolección
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

    // 3. Crear el documento del Pago
    final pagoRef = _db.collection('pago').doc();
    batch.set(pagoRef, {
      'id': pagoRef.id,
      'orden_id': ordenRef.id,
      'metodo_pago': 'tarjeta',
      'monto': total,
      'referencia': '1234589', // Simulación del código de autorización
      'fecha_hora': FieldValue.serverTimestamp(),
    });

    // Subir todo a la nube
    await batch.commit();
  }
}
