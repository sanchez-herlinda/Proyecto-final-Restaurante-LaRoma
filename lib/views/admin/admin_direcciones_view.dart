import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/direccion_model.dart';

class AdminDireccionesView extends StatelessWidget {
  const AdminDireccionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('direcciones')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay direcciones registradas.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final dir = Direccion.fromJson(
                  doc.data() as Map<String, dynamic>, doc.id);

              return Card(
                color: AppColors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: AppColors.dividerLine),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.backgroundBeige,
                    child:
                        Icon(Icons.location_on, color: AppColors.primaryBrown),
                  ),
                  title: Text(dir.alias,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${dir.calleYNumero}, Col. ${dir.colonia}\nCP: ${dir.codigoPostal}'),
                  isThreeLine: true,
                  trailing:
                      const Icon(Icons.edit, color: Colors.grey, size: 20),
                  onTap: () => _mostrarFormulario(context,
                      docReference: doc.reference, direccion: dir),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarFormulario(BuildContext context,
      {required DocumentReference docReference, required Direccion direccion}) {
    final aliasCtrl = TextEditingController(text: direccion.alias);
    final calleCtrl = TextEditingController(text: direccion.calleYNumero);
    final colCtrl = TextEditingController(text: direccion.colonia);
    final cpCtrl = TextEditingController(text: direccion.codigoPostal);
    final refCtrl = TextEditingController(text: direccion.indicaciones);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (context) {
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
                const Text('Editar Dirección',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                    controller: aliasCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Alias (Ej: Casa)')),
                TextField(
                    controller: calleCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Calle y Número')),
                TextField(
                    controller: colCtrl,
                    decoration: const InputDecoration(labelText: 'Colonia')),
                TextField(
                    controller: cpCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Código Postal')),
                TextField(
                    controller: refCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Indicaciones extra')),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (aliasCtrl.text.isEmpty || calleCtrl.text.isEmpty) {
                      return; // CORRECCIÓN: Encerrado en llaves
                    }

                    final data = {
                      'alias': aliasCtrl.text.trim(),
                      'calle_y_numero': calleCtrl.text.trim(),
                      'colonia': colCtrl.text.trim(),
                      'codigo_postal': cpCtrl.text.trim(),
                      'indicaciones': refCtrl.text.trim(),
                    };

                    await docReference.update(data);

                    if (!context.mounted) {
                      return; // CORRECCIÓN: Encerrado en llaves
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar Cambios'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await docReference.delete();
                    if (!context.mounted) {
                      return; // CORRECCIÓN: Encerrado en llaves
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Eliminar Dirección',
                      style: TextStyle(color: AppColors.errorRed)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
