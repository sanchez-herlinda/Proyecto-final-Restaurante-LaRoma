import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/reservacion_model.dart';
import 'crear_reservacion_view.dart';

class MisReservacionesView extends StatelessWidget {
  const MisReservacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().authState.data?.id;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Mis Reservaciones'),
        backgroundColor: AppColors.white,
      ),
      body: userId == null
          ? const Center(child: Text('Inicia sesión para ver tus reservas.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reservacion')
                  .where('cliente_id', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tienes reservaciones.'));
                }

                final docs = snapshot.data!.docs.toList();
                docs.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['fecha_hora']
                      as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['fecha_hora']
                      as Timestamp?;
                  return (bTime?.toDate() ??
                          DateTime.fromMillisecondsSinceEpoch(0))
                      .compareTo(aTime?.toDate() ??
                          DateTime.fromMillisecondsSinceEpoch(0));
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final res = Reservacion.fromJson(
                        docs[index].data() as Map<String, dynamic>,
                        docs[index].id);
                    final fechaFormat =
                        DateFormat('EEEE, dd MMM yyyy - hh:mm a')
                            .format(res.fechaHora);

                    Color estadoColor = Colors.orange;
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event_seat,
                                        color: AppColors.primaryBrown),
                                    const SizedBox(width: 8),
                                    Text(fechaFormat,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: estadoColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(res.estado.toUpperCase(),
                                      style: TextStyle(
                                          color: estadoColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10)),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.dividerLine),
                            const SizedBox(height: 8),
                            Text('${res.numPersonas} Personas',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            if (res.mesaId.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Mesa asignada: ${res.mesaId}',
                                  style: const TextStyle(
                                      color: AppColors.successGreen)),
                            ],
                            if (res.notas.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Notas: ${res.notas}',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBrown,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Nueva Reserva',
            style: TextStyle(color: AppColors.white)),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CrearReservacionView()));
        },
      ),
    );
  }
}
