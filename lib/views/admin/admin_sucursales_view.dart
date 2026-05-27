import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class AdminSucursalesView extends StatelessWidget {
  const AdminSucursalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sucursal').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay sucursales registradas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final sucursalId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final bool disponible = data['disponible'] ?? true;

              return Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                      color: disponible
                          ? AppColors.dividerLine
                          : AppColors.errorRed),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: disponible
                        ? AppColors.successGreen.withValues(alpha: 0.2)
                        : AppColors.errorRed.withValues(alpha: 0.2),
                    child: Icon(Icons.storefront,
                        color: disponible
                            ? AppColors.successGreen
                            : AppColors.errorRed),
                  ),
                  title: Text(data['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${data['direccion']}\nHorario: ${data['horario']}'),
                  isThreeLine: true,
                  trailing: Icon(disponible ? Icons.check_circle : Icons.cancel,
                      color: Colors.grey),
                  onTap: () => _mostrarFormularioSucursal(context,
                      sucursalId: sucursalId, dataActual: data),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBrown,
        onPressed: () => _mostrarFormularioSucursal(context),
        child: const Icon(Icons.add_business, color: AppColors.white),
      ),
    );
  }

  void _mostrarFormularioSucursal(BuildContext context,
      {String? sucursalId, Map<String, dynamic>? dataActual}) {
    final bool isEditing = sucursalId != null;

    final nombreCtrl = TextEditingController(text: dataActual?['nombre'] ?? '');
    final direccionCtrl =
        TextEditingController(text: dataActual?['direccion'] ?? '');
    final horarioCtrl =
        TextEditingController(text: dataActual?['horario'] ?? '');
    bool isDisponible = dataActual?['disponible'] ?? true;

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
                  Text(isEditing ? 'Editar Sucursal' : 'Nueva Sucursal',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre de la Sucursal (Ej: Centro)')),
                  TextField(
                      controller: direccionCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Dirección Completa')),
                  TextField(
                      controller: horarioCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Horario (Ej: 9:00 am - 9:00 pm)')),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Sucursal Abierta / Disponible'),
                    activeThumbColor: AppColors.primaryBrown,
                    value: isDisponible,
                    onChanged: (val) => setModalState(() => isDisponible = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (nombreCtrl.text.isEmpty ||
                          direccionCtrl.text.isEmpty) {
                        return;
                      }

                      final data = {
                        'nombre': nombreCtrl.text.trim(),
                        'direccion': direccionCtrl.text.trim(),
                        'horario': horarioCtrl.text.trim(),
                        'disponible': isDisponible,
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('sucursal')
                            .doc(sucursalId)
                            .update(data);
                      } else {
                        final nuevoId =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        data['id'] = nuevoId;
                        await FirebaseFirestore.instance
                            .collection('sucursal')
                            .doc(nuevoId)
                            .set(data);
                      }

                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar Sucursal'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('sucursal')
                            .doc(sucursalId)
                            .delete();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Eliminar Sucursal',
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
