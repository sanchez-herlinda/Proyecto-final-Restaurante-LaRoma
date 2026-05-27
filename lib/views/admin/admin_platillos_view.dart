import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/platillo_model.dart';

class AdminPlatillosView extends StatelessWidget {
  const AdminPlatillosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      // READ: Leemos los platillos en tiempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('platillo').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay platillos en el menú.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final platillo = Platillo.fromJson(
                  docs[index].data() as Map<String, dynamic>, docs[index].id);

              return Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                      color: platillo.disponible
                          ? AppColors.dividerLine
                          : AppColors.errorRed),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(platillo.imagenUrl),
                    backgroundColor: AppColors.backgroundBeige,
                  ),
                  title: Text(platillo.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${platillo.categoriaId} • \$${platillo.precio}'),
                  trailing: Icon(
                      platillo.disponible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey),
                  onTap: () => _mostrarFormularioPlatillo(context,
                      platillo: platillo), // UPDATE / DELETE
                ),
              );
            },
          );
        },
      ),
      // CREATE: Botón para agregar nuevo
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBrown,
        onPressed: () => _mostrarFormularioPlatillo(context),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  // Formulario Reutilizable para Crear y Editar
  void _mostrarFormularioPlatillo(BuildContext context, {Platillo? platillo}) {
    final isEditing = platillo != null;

    final nombreCtrl =
        TextEditingController(text: isEditing ? platillo.nombre : '');
    final descCtrl =
        TextEditingController(text: isEditing ? platillo.descripcion : '');
    final precioCtrl = TextEditingController(
        text: isEditing ? platillo.precio.toString() : '');
    final catCtrl = TextEditingController(
        text: isEditing ? platillo.categoriaId : 'Primeros');
    final imgCtrl =
        TextEditingController(text: isEditing ? platillo.imagenUrl : '');
    bool isDisponible = isEditing ? platillo.disponible : true;

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
                  Text(isEditing ? 'Editar Platillo' : 'Nuevo Platillo',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del platillo')),
                  TextField(
                      controller: catCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Categoría (Ej: Postres, Bebidas)')),
                  TextField(
                      controller: descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Descripción')),
                  TextField(
                      controller: precioCtrl,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number),
                  TextField(
                      controller: imgCtrl,
                      decoration: const InputDecoration(
                          labelText: 'URL de Imagen (GitHub)')),
                  SwitchListTile(
                    title: const Text('Disponible para venta'),
                    activeThumbColor: AppColors
                        .primaryBrown, // Corrección de la advertencia deprecated
                    value: isDisponible,
                    onChanged: (val) => setModalState(() => isDisponible = val),
                  ),
                  const SizedBox(height: 16),

                  // Botón Guardar (Create / Update)
                  ElevatedButton(
                    onPressed: () async {
                      if (nombreCtrl.text.isEmpty || precioCtrl.text.isEmpty) {
                        return; // Corrección de llaves
                      }

                      final data = {
                        'nombre': nombreCtrl.text,
                        'categoriaId': catCtrl.text,
                        'descripcion': descCtrl.text,
                        'precio': double.tryParse(precioCtrl.text) ?? 0.0,
                        'imagenUrl': imgCtrl.text,
                        'disponible': isDisponible,
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('platillo')
                            .doc(platillo.id)
                            .update(data);
                      } else {
                        data['id'] = DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(); // ID temporal manual
                        await FirebaseFirestore.instance
                            .collection('platillo')
                            .doc(data['id'] as String)
                            .set(data);
                      }

                      if (!context.mounted) {
                        return; // Corrección de llaves
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar Platillo'),
                  ),

                  // Botón Eliminar (Solo si estamos editando)
                  if (isEditing) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('platillo')
                            .doc(platillo.id)
                            .delete();
                        if (!context.mounted) {
                          return; // Corrección de llaves
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Eliminar Platillo',
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
