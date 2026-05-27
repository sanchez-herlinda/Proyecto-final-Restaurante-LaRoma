import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class CuentaView extends StatefulWidget {
  const CuentaView({super.key});

  @override
  State<CuentaView> createState() => _CuentaViewState();
}

class _CuentaViewState extends State<CuentaView> {
  final _nombreController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  bool _cargando = true;
  String _fotoActual = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosDeFirebase();
  }

  Future<void> _cargarDatosDeFirebase() async {
    final userId = context.read<AuthProvider>().authState.data?.id;
    if (userId != null) {
      // Leemos directamente el documento del usuario para obtener su foto actual
      final doc = await FirebaseFirestore.instance
          .collection('empleado')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nombreController.text = data['nombre'] ?? '';
          _fotoUrlController.text = data['fotoUrl'] ?? '';
          _fotoActual = data['fotoUrl'] ?? '';
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final userId = context.read<AuthProvider>().authState.data?.id;
    if (userId == null) return;

    // Mostrar un indicador de carga
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await context.read<AuthProvider>().actualizarPerfil(userId,
          _nombreController.text.trim(), _fotoUrlController.text.trim());

      if (!mounted) return;
      Navigator.pop(context); // Quitar loader

      setState(() {
        _fotoActual = _fotoUrlController.text.trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: AppColors.successGreen),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Quitar loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el email del Provider, ya que ese no se debería poder editar fácilmente
    final email = context.watch<AuthProvider>().authState.data?.email ??
        'correo@ejemplo.com';

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
        backgroundColor: AppColors.white,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrown))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // FOTO DE PERFIL CIRCULAR
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.primaryBrown, width: 3),
                        color: AppColors.white,
                      ),
                      child: ClipOval(
                        child: _fotoActual.isEmpty
                            ? const Icon(CupertinoIcons.person_fill,
                                size: 80, color: Colors.grey)
                            : CachedNetworkImage(
                                imageUrl: _fotoActual,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // FORMULARIO
                  const Text('Nombre Completo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                      controller: _nombreController, hintText: 'Ej: Ricardo'),

                  const SizedBox(height: 20),
                  const Text('Correo Electrónico (No editable)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(email,
                        style: const TextStyle(color: Colors.black54)),
                  ),

                  const SizedBox(height: 20),
                  const Text('Enlace de Foto de Perfil (GitHub URL)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildTextField(
                      controller: _fotoUrlController,
                      hintText: 'https://raw.githubusercontent.com/...'),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _guardarCambios,
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String hintText}) {
    return Container(
      color: AppColors.white.withValues(alpha: 0.5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.backgroundBeige.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
