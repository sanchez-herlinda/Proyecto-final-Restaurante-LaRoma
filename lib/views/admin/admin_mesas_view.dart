import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/reservacion_model.dart';
import '../../providers/sucursales_provider.dart';

class AdminMesasView extends StatelessWidget {
  const AdminMesasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('mesa').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay mesas registradas.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final mesa = Mesa.fromJson(
                  docs[index].data() as Map<String, dynamic>, docs[index].id);

              Color estadoColor = AppColors.successGreen;
              if (mesa.estado == 'ocupada') {
                estadoColor = AppColors.errorRed;
              }
              if (mesa.estado == 'reservada') {
                estadoColor = Colors.orange;
              }

              return Card(
                color: AppColors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: estadoColor.withValues(alpha: 0.2),
                    child: Icon(Icons.table_restaurant, color: estadoColor),
                  ),
                  title: Text('Mesa ${mesa.numero} - ${mesa.ubicacion}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Capacidad: ${mesa.capacidad} personas\nSucursal ID: ${mesa.sucursalId.substring(0, 5)}...'),
                  isThreeLine: true,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(mesa.estado.toUpperCase(),
                        style: TextStyle(
                            color: estadoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ),
                  onTap: () => _mostrarFormulario(context, mesa: mesa),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBrown,
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Mesa? mesa}) {
    final bool isEditing = mesa != null;
    final sucursales = context.read<SucursalesProvider>().sucursales;

    final numCtrl = TextEditingController(text: mesa?.numero ?? '');
    final capCtrl =
        TextEditingController(text: mesa?.capacidad.toString() ?? '2');
    String ubiSeleccionada = mesa?.ubicacion ?? 'Interior';
    String estadoSeleccionado = mesa?.estado ?? 'libre';

    // CORRECCIÓN: Como Dart ya analizó que isEditing significa que mesa NO es nula, usamos "." normal.
    String? sucursalSeleccionada = isEditing
        ? mesa.sucursalId
        : (sucursales.isNotEmpty ? sucursales.first.id : null);

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
                  Text(isEditing ? 'Editar Mesa' : 'Nueva Mesa',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Asignar a Sucursal:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButtonFormField<String>(
                    initialValue: sucursalSeleccionada,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: sucursales
                        .map((s) => DropdownMenuItem(
                            value: s.id, child: Text(s.nombre)))
                        .toList(),
                    onChanged: (val) => setModalState(() {
                      if (val != null) {
                        sucursalSeleccionada = val;
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: numCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Número o Nombre'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextField(
                              controller: capCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Capacidad'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Ubicación:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButtonFormField<String>(
                    initialValue: ubiSeleccionada,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: 'Interior', child: Text('Interior')),
                      DropdownMenuItem(
                          value: 'Terraza', child: Text('Terraza')),
                      DropdownMenuItem(
                          value: 'Ventana', child: Text('Junto a la ventana')),
                      DropdownMenuItem(value: 'VIP', child: Text('Zona VIP')),
                    ],
                    onChanged: (val) => setModalState(() {
                      if (val != null) {
                        ubiSeleccionada = val;
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Text('Estado:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButtonFormField<String>(
                    initialValue: estadoSeleccionado,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'libre', child: Text('Libre')),
                      DropdownMenuItem(
                          value: 'ocupada', child: Text('Ocupada')),
                      DropdownMenuItem(
                          value: 'reservada', child: Text('Reservada')),
                    ],
                    onChanged: (val) => setModalState(() {
                      if (val != null) {
                        estadoSeleccionado = val;
                      }
                    }),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (numCtrl.text.isEmpty ||
                          sucursalSeleccionada == null) {
                        return;
                      }

                      final data = {
                        'sucursal_id': sucursalSeleccionada,
                        'numero': numCtrl.text.trim(),
                        'capacidad': int.tryParse(capCtrl.text) ?? 2,
                        'ubicacion': ubiSeleccionada,
                        'estado': estadoSeleccionado,
                      };

                      if (isEditing) {
                        // CORRECCIÓN: "." normal gracias a la inteligencia de Dart
                        await FirebaseFirestore.instance
                            .collection('mesa')
                            .doc(mesa.id)
                            .update(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('mesa')
                            .add(data);
                      }

                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar Mesa'),
                  ),
                  if (isEditing) ...[
                    TextButton(
                      onPressed: () async {
                        // CORRECCIÓN: "." normal
                        await FirebaseFirestore.instance
                            .collection('mesa')
                            .doc(mesa.id)
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
