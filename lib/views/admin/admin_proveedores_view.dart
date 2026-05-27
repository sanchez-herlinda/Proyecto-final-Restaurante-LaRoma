import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/inventario_model.dart';

class AdminProveedoresView extends StatelessWidget {
  const AdminProveedoresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('proveedor').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay proveedores registrados.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final prov = Proveedor.fromJson(
                  docs[index].data() as Map<String, dynamic>, docs[index].id);

              return Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                      color: prov.activo
                          ? AppColors.dividerLine
                          : AppColors.errorRed),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: prov.activo
                        ? AppColors.primaryBrown.withValues(alpha: 0.1)
                        : AppColors.errorRed.withValues(alpha: 0.1),
                    child: Icon(Icons.local_shipping,
                        color: prov.activo
                            ? AppColors.primaryBrown
                            : AppColors.errorRed),
                  ),
                  title: Text(prov.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Contacto: ${prov.contacto}\nTel: ${prov.telefono}\nEmail: ${prov.email}'),
                  isThreeLine: true,
                  trailing: Icon(
                      prov.activo ? Icons.check_circle : Icons.cancel,
                      color: Colors.grey),
                  onTap: () => _mostrarFormulario(context, proveedor: prov),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBrown,
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(Icons.add_business, color: AppColors.white),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Proveedor? proveedor}) {
    final bool isEditing = proveedor != null;

    final nombreCtrl = TextEditingController(text: proveedor?.nombre ?? '');
    final contactoCtrl = TextEditingController(text: proveedor?.contacto ?? '');
    final telefonoCtrl = TextEditingController(text: proveedor?.telefono ?? '');
    final emailCtrl = TextEditingController(text: proveedor?.email ?? '');
    final direccionCtrl =
        TextEditingController(text: proveedor?.direccion ?? '');
    bool isActivo = proveedor?.activo ?? true;

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
                top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre de la Empresa')),
                  TextField(
                      controller: contactoCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del Contacto')),
                  TextField(
                      controller: telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Teléfono')),
                  TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Correo Electrónico')),
                  TextField(
                      controller: direccionCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Dirección Completa')),
                  SwitchListTile(
                    title: const Text('Proveedor Activo'),
                    activeThumbColor: AppColors.primaryBrown,
                    value: isActivo,
                    onChanged: (val) => setModalState(() => isActivo = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (nombreCtrl.text.isEmpty) {
                        return;
                      }
                      final data = {
                        'nombre': nombreCtrl.text.trim(),
                        'contacto': contactoCtrl.text.trim(),
                        'telefono': telefonoCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'direccion': direccionCtrl.text.trim(),
                        'activo': isActivo,
                      };
                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('proveedor')
                            .doc(proveedor.id)
                            .update(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('proveedor')
                            .add(data);
                      }
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                  if (isEditing) ...[
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('proveedor')
                            .doc(proveedor.id)
                            .delete();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Eliminar',
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
