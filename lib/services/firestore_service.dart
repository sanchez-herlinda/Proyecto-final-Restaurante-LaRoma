import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener un documento específico (ej. el perfil del empleado/usuario)
  Future<DocumentSnapshot> getDocument(String collection, String id) async {
    return await _db.collection(collection).doc(id).get();
  }

  // Guardar o actualizar un documento
  Future<void> setDocument(
      String collection, String id, Map<String, dynamic> data) async {
    return await _db.collection(collection).doc(id).set(data);
  }
}
