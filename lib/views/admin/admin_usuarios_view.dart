import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class AdminUsuariosView extends StatelessWidget {
  const AdminUsuariosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('empleado').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final userId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final rolActual = data['rol'] ?? 'usuario';
              final bool isAdmin = rolActual == 'admin';

              return Card(
                color: AppColors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isAdmin ? AppColors.primaryBrown : Colors.grey.shade300,
                    child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: isAdmin ? AppColors.white : AppColors.textDark),
                  ),
                  title: Text(data['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['email'] ?? 'Sin correo'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: isAdmin
                        ? AppColors.primaryBrown.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    child: Text(rolActual.toString().toUpperCase(),
                        style: TextStyle(
                            color: isAdmin
                                ? AppColors.primaryBrown
                                : AppColors.textDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => _mostrarFormularioUsuario(context,
                      userId: userId, dataActual: data),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBrown,
        onPressed: () => _mostrarFormularioUsuario(context),
        child: const Icon(Icons.person_add, color: AppColors.white),
      ),
    );
  }

  void _mostrarFormularioUsuario(BuildContext context,
      {String? userId, Map<String, dynamic>? dataActual}) {
    final bool isEditing = userId != null;

    // CORRECCIÓN: Usamos solo el operador nulo (??) para no confundir a Dart
    final nombreCtrl = TextEditingController(text: dataActual?['nombre'] ?? '');
    final emailCtrl = TextEditingController(text: dataActual?['email'] ?? '');
    String rolSeleccionado = dataActual?['rol'] ?? 'usuario';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      isEditing ? 'Modificar Usuario' : 'Nuevo Usuario Alterno',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del usuario')),
                  TextField(
                    controller: emailCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Correo Electrónico'),
                    enabled: !isEditing,
                  ),
                  const SizedBox(height: 16),
                  const Text('Rol asignado:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButtonFormField<String>(
                    initialValue:
                        rolSeleccionado, // CORRECCIÓN: initialValue en lugar de value
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: 'usuario', child: Text('Usuario / Cliente')),
                      DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administrador de Sistema')),
                    ],
                    onChanged: (val) => setModalState(() {
                      if (val != null) {
                        rolSeleccionado = val;
                      }
                    }),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (nombreCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                        return;
                      }

                      final mapaDatos = {
                        'nombre': nombreCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'rol': rolSeleccionado,
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('empleado')
                            .doc(userId)
                            .update(mapaDatos);
                      } else {
                        final nuevoId =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        mapaDatos['id'] = nuevoId;
                        await FirebaseFirestore.instance
                            .collection('empleado')
                            .doc(nuevoId)
                            .set(mapaDatos);
                      }

                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar Datos'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('empleado')
                            .doc(userId)
                            .delete();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Cuenta eliminada de la base de datos'),
                              backgroundColor: AppColors.errorRed),
                        );
                      },
                      child: const Text('Eliminar Cuenta del Sistema',
                          style: TextStyle(color: AppColors.errorRed)),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
