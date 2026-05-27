import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/platillo_model.dart';
import '../core/utils/ui_state.dart';

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Base URL de tu repositorio de GitHub para las imágenes
  final String _baseUrl =
      "https://raw.githubusercontent.com/sanchez-herlinda/Imagenes_para_Flutter_6J-11-Feb-2026/refs/heads/main/";

  UIState<List<Platillo>> _menuState = UIState.initial();
  UIState<List<Platillo>> get menuState => _menuState;

  MenuProvider() {
    cargarMenuFirebase(); // Intentamos cargar desde la nube al iniciar la app
  }

  // 1. Método real para descargar el menú desde Firebase
  Future<void> cargarMenuFirebase() async {
    // Si no estamos inicializando, avisamos a la UI que estamos cargando
    if (_menuState.status != UIStateStatus.initial) {
      _menuState = UIState.loading();
      notifyListeners();
    }

    try {
      // Consultamos la colección 'platillo' buscando solo los disponibles
      QuerySnapshot snapshot = await _db
          .collection('platillo')
          .where('disponible', isEqualTo: true)
          .get();

      List<Platillo> platillos = snapshot.docs.map((doc) {
        return Platillo.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _menuState = UIState.success(platillos);
    } catch (e) {
      _menuState = UIState.error('Error al cargar menú: $e');
    }

    notifyListeners();
  }

  // 2. TRUCO TEMPORAL: Sube datos iniciales a tu base de datos vacía
  Future<void> subirDatosDePrueba() async {
    final List<Platillo> mockData = [
      Platillo(
          id: '1',
          categoriaId: 'Primeros',
          nombre: 'Risotto',
          descripcion:
              'Plato tradicional del norte de Italia, reconocido por su textura cremosa.',
          precio: 50.0,
          imagenUrl: '$_baseUrl/risotto.png'),
      Platillo(
          id: '2',
          categoriaId: 'Postres',
          nombre: 'Cannoli',
          descripcion: 'Dulce tradicional siciliano relleno de ricotta dulce.',
          precio: 45.0,
          imagenUrl: '$_baseUrl/cannoli.png'),
      Platillo(
          id: '3',
          categoriaId: 'Bebidas',
          nombre: 'Vino Tinto',
          descripcion:
              'Vino tinto de la casa, ideal para acompañar carnes y pastas.',
          precio: 50.0,
          imagenUrl: '$_baseUrl/vino_tinto.png'),
      Platillo(
          id: '4',
          categoriaId: 'Postres',
          nombre: 'Baba',
          descripcion: 'Rico y tradicional bizcocho empapado en ron.',
          precio: 201.0,
          imagenUrl: '$_baseUrl/baba.png'),
      Platillo(
          id: '5',
          categoriaId: 'Postres',
          nombre: 'Tiramisu',
          descripcion: 'Clásico postre italiano a base de café y mascarpone.',
          precio: 85.0,
          imagenUrl: '$_baseUrl/tiramisu.png'),
      Platillo(
          id: '6',
          categoriaId: 'Postres',
          nombre: 'Panna Cotta',
          descripcion: 'Postre de crema cocida con coulis de frutos rojos.',
          precio: 70.0,
          imagenUrl: '$_baseUrl/panna_cotta.png'),
      Platillo(
          id: '7',
          categoriaId: 'Postres',
          nombre: 'Zeppole',
          descripcion: 'Bocaditos de masa frita espolvoreados con azúcar.',
          precio: 60.0,
          imagenUrl: '$_baseUrl/zeppole.png'),
      Platillo(
          id: '8',
          categoriaId: 'Postres',
          nombre: 'Gelato',
          descripcion: 'Helado artesanal italiano estilo tradicional.',
          precio: 45.0,
          imagenUrl: '$_baseUrl/gelato.png'),
    ];

    try {
      // Usamos un batch para enviar todo de golpe a Firestore
      WriteBatch batch = _db.batch();

      for (var platillo in mockData) {
        DocumentReference docRef = _db.collection('platillo').doc(platillo.id);
        batch.set(docRef, platillo.toJson());
      }

      await batch.commit(); // Ejecutamos la subida
      await cargarMenuFirebase(); // Recargamos el menú para ver los cambios
    } catch (e) {
      throw Exception("Error subiendo datos a Firebase: $e");
    }
  }
}
