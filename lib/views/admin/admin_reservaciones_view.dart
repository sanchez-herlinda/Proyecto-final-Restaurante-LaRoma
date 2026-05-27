import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/reservacion_model.dart';

class AdminReservacionesView extends StatelessWidget {
  const AdminReservacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('reservacion').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay reservaciones.'));
          }

          final docs = snapshot.data!.docs.toList();
          // Ordenamos para ver las más próximas primero
          docs.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['fecha_hora'] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['fecha_hora'] as Timestamp?;
            return (aTime?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                    bTime?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final res = Reservacion.fromJson(
                  docs[index].data() as Map<String, dynamic>, docs[index].id);
              final fechaFormat =
                  DateFormat('dd/MM/yyyy - hh:mm a').format(res.fechaHora);

              Color estadoColor = Colors.orange; // pendiente
              if (res.estado == 'confirmada') {
                estadoColor = AppColors.successGreen;
              }
              if (res.estado == 'cancelada') {
                estadoColor = AppColors.errorRed;
              }

              return Card(
                color: AppColors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: AppColors.primaryBrown, size: 36),
                  title: Text(fechaFormat,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${res.numPersonas} Personas\nNotas: ${res.notas}'),
                  isThreeLine: true,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(res.estado.toUpperCase(),
                        style: TextStyle(
                            color: estadoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ),
                  onTap: () => _mostrarDetalles(context, res, estadoColor),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDetalles(
      BuildContext context, Reservacion res, Color estadoColor) {
    String estadoSeleccionado = res.estado;

    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Detalles de Reservación',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 24)),
                  const Divider(color: AppColors.dividerLine),
                  Text('ID Cliente: ${res.clienteId}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                      'Mesa Asignada: ${res.mesaId.isEmpty ? 'Ninguna' : res.mesaId}'),
                  const SizedBox(height: 16),
                  const Text('Cambiar Estado:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    initialValue: estadoSeleccionado,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: 'pendiente', child: Text('Pendiente')),
                      DropdownMenuItem(
                          value: 'confirmada', child: Text('Confirmada')),
                      DropdownMenuItem(
                          value: 'cancelada', child: Text('Cancelada')),
                    ],
                    onChanged: (val) => setModalState(() {
                      if (val != null) estadoSeleccionado = val;
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('reservacion')
                          .doc(res.id)
                          .update({'estado': estadoSeleccionado});
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Reservación actualizada')));
                    },
                    child: const Text('Actualizar Estado'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('reservacion')
                          .doc(res.id)
                          .delete();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Eliminar Registro',
                        style: TextStyle(color: AppColors.errorRed)),
                  ),
                ],
              ),
            );
          });
        });
  }
}
