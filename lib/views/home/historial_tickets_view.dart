import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class HistorialTicketsView extends StatelessWidget {
  const HistorialTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().authState;
    final clienteId = authState.data?.id;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Mis Tickets'),
        backgroundColor: AppColors.white,
      ),
      body: clienteId == null
          ? const Center(child: Text('Inicia sesión para ver tus compras.'))
          : StreamBuilder<QuerySnapshot>(
              // Le quitamos el orderBy para no requerir índice en Firebase
              stream: FirebaseFirestore.instance
                  .collection('orden')
                  .where('cliente_id', isEqualTo: clienteId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBrown));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Aún no tienes compras.',
                          style: TextStyle(
                              color: AppColors.textDark, fontSize: 18)));
                }

                // 🔴 ORDENAMOS LOCALMENTE POR FECHA DESCENDENTE
                final ordenes = snapshot.data!.docs.toList();
                ordenes.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = (aData['fecha_hora'] as Timestamp?)?.toDate() ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final bTime = (bData['fecha_hora'] as Timestamp?)?.toDate() ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordenes.length,
                  itemBuilder: (context, index) {
                    final data = ordenes[index].data() as Map<String, dynamic>;
                    final fecha =
                        (data['fecha_hora'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                    final fechaFormateada =
                        DateFormat('dd/MM/yyyy - hh:mm a').format(fecha);

                    return Card(
                      color: AppColors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
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
                                    const Icon(CupertinoIcons.ticket,
                                        color: AppColors.primaryBrown),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Orden #${data['id'].toString().substring(0, 5)}...',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  color: AppColors.successGreen
                                      .withValues(alpha: 0.2),
                                  child: Text(
                                    data['estado'].toString().toUpperCase(),
                                    style: const TextStyle(
                                        color: AppColors.successGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.dividerLine),
                            const SizedBox(height: 8),
                            Text('Fecha: $fechaFormateada',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Pagado:'),
                                Text('\$${data['total']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColors.textDark)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
