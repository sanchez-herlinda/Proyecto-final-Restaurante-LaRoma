import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class AdminOrdenesView extends StatelessWidget {
  const AdminOrdenesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orden').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs.toList() ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay órdenes registradas.'));
          }

          docs.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['fecha_hora'] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['fecha_hora'] as Timestamp?;
            return (bTime?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                    aTime?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final ordenId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final fecha = (data['fecha_hora'] as Timestamp?)?.toDate() ??
                  DateTime.now();
              final fechaFormat =
                  DateFormat('dd/MM/yyyy - hh:mm a').format(fecha);
              final estado = data['estado'] ?? 'pendiente';

              Color estadoColor = Colors.grey;
              if (estado == 'pendiente') {
                estadoColor = Colors.orange;
              }
              if (estado == 'preparando') {
                estadoColor = Colors.blue;
              }
              if (estado == 'entregado') {
                estadoColor = AppColors.successGreen;
              }
              if (estado == 'cancelado') {
                estadoColor = AppColors.errorRed;
              }

              return Card(
                color: AppColors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading:
                      Icon(Icons.receipt_long, color: estadoColor, size: 36),
                  title: Text('Orden #${ordenId.substring(0, 5).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$fechaFormat\nTotal: \$${data['total']}'),
                  isThreeLine: true,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(estado.toString().toUpperCase(),
                        style: TextStyle(
                            color: estadoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ),
                  onTap: () => _mostrarDetallesOrden(
                      context, ordenId, data, estadoColor),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDetallesOrden(BuildContext context, String ordenId,
      Map<String, dynamic> data, Color estadoColor) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Detalles de la Orden',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontSize: 24)),
                            Text('ID: $ordenId',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      // 🔴 ACCIÓN: ELIMINAR ORDEN DIRECTAMENTE
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: AppColors.errorRed, size: 30),
                        onPressed: () async {
                          final confirmar =
                              await _mostrarDialogoConfirmacion(context);
                          if (confirmar == true) {
                            await FirebaseFirestore.instance
                                .collection('orden')
                                .doc(ordenId)
                                .delete();
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Orden eliminada permanentemente'),
                                  backgroundColor: AppColors.errorRed),
                            );
                          }
                        },
                      )
                    ],
                  ),
                  const Divider(color: AppColors.dividerLine),
                  const SizedBox(height: 10),
                  const Text('Cambiar Estado:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    initialValue: data['estado'] ?? 'pendiente',
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: 'pendiente', child: Text('Pendiente')),
                      DropdownMenuItem(
                          value: 'preparando', child: Text('Preparando')),
                      DropdownMenuItem(
                          value: 'en_camino', child: Text('En Camino')),
                      DropdownMenuItem(
                          value: 'entregado', child: Text('Entregado')),
                      DropdownMenuItem(
                          value: 'cancelado', child: Text('Cancelado')),
                    ],
                    onChanged: (nuevoEstado) async {
                      if (nuevoEstado != null) {
                        await FirebaseFirestore.instance
                            .collection('orden')
                            .doc(ordenId)
                            .update({'estado': nuevoEstado});
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Estado actualizado')));
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Platillos Solicitados:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orden')
                          .doc(ordenId)
                          .collection('detalle_orden')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No hay detalles registrados.');
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final detalle = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                  '${detalle['cantidad']}x ${detalle['nombre_platillo']}'),
                              trailing: Text(
                                  '\$${detalle['precio_unitario'] * detalle['cantidad']}'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(color: AppColors.dividerLine),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a pagar:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('\$${data['total']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primaryBrown)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar')),
                ],
              ),
            ),
          );
        });
  }

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: const Text(
            'Esta acción quitará la orden de la base de datos de manera irreversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textDark))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
