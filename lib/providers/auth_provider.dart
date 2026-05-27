import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/empleado_model.dart';
import '../core/utils/ui_state.dart';
import 'perfil_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UIState<Empleado> _authState = UIState.initial();
  UIState<Empleado> get authState => _authState;

  Future<void> login(String email, String password) async {
    _authState = UIState.loading();
    notifyListeners(); // Avisa a la pantalla que muestre el ícono de carga

    try {
      // 1. Intentar hacer login en Firebase Auth
      UserCredential userCred = await _authService.signIn(email, password);

      if (userCred.user != null) {
        // 2. Buscar qué rol tiene ese usuario en la colección 'empleado'
        var doc =
            await _firestoreService.getDocument('empleado', userCred.user!.uid);

        if (doc.exists) {
          Empleado empleado =
              Empleado.fromJson(doc.data() as Map<String, dynamic>, doc.id);
          _authState = UIState.success(empleado); // Login exitoso
        } else {
          // Si no está en la base de datos, lo tratamos como cliente/usuario normal
          Empleado usuarioBase = Empleado(
              id: userCred.user!.uid,
              nombre: 'Usuario',
              rol: 'usuario',
              email: email);
          _authState = UIState.success(usuarioBase);
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores amigable
      String errorMsg = 'Error al iniciar sesión';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorMsg = 'Correo o contraseña incorrectos.';
      }
      _authState = UIState.error(errorMsg);
    } catch (e) {
      _authState = UIState.error("Error inesperado: ${e.toString()}");
    }

    notifyListeners(); // Avisa a la pantalla que ya terminó
  }

  Future<void> registro(String nombre, String email, String password) async {
    _authState = UIState.loading();
    notifyListeners();

    try {
      // 1. Crear el usuario en Firebase Auth
      UserCredential userCred = await _authService.signUp(email, password);

      if (userCred.user != null) {
        // 2. Crear el objeto de usuario y guardarlo en Firestore
        Empleado nuevoUsuario = Empleado(
          id: userCred.user!.uid,
          nombre: nombre,
          rol: 'usuario', // Rol por defecto para clientes nuevos
          email: email,
        );

        await _firestoreService.setDocument(
            'empleado', userCred.user!.uid, nuevoUsuario.toJson());

        _authState = UIState.success(nuevoUsuario);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Error al registrarse';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'El correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'La contraseña es muy débil (mínimo 6 caracteres).';
      }
      _authState = UIState.error(errorMsg);
    } catch (e) {
      _authState = UIState.error("Error inesperado: ${e.toString()}");
    }

    notifyListeners();
  }

  Future<void> logout(PerfilProvider perfilProvider) async {
    await _authService.signOut();

    // 1. Limpiamos las listas de direcciones y tarjetas del usuario anterior
    perfilProvider.limpiarPerfil();

    // 2. Reiniciamos el estado de autenticación
    _authState = UIState.initial();
    notifyListeners();
  }

// NUEVA FUNCIÓN: Actualizar datos del perfil
  Future<void> actualizarPerfil(
      String userId, String nuevoNombre, String nuevaFotoUrl) async {
    try {
      // 1. Actualizar en Firestore directamente usando update()
      // Esto solo modifica los campos indicados sin tocar el resto (email, rol, etc.)
      await FirebaseFirestore.instance
          .collection('empleado')
          .doc(userId)
          .update({
        'nombre': nuevoNombre,
        'fotoUrl': nuevaFotoUrl,
      });

      // 2. Actualizar el estado local de la app para que la pantalla cambie al instante
      if (_authState.data != null) {
        Empleado usuarioActualizado = Empleado(
          id: _authState.data!.id,
          nombre: nuevoNombre,
          rol: _authState.data!.rol,
          email: _authState.data!.email,
        );
        _authState = UIState.success(usuarioActualizado);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al actualizar perfil: $e");
      throw Exception("No se pudo actualizar el perfil");
    }
  }
}
