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
        title: const Text('Mis Tickets',
            style: TextStyle(
                fontFamily: 'Times New Roman', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: clienteId == null
          ? const Center(child: Text('Inicia sesión para ver tus compras.'))
          : StreamBuilder<QuerySnapshot>(
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
                        style:
                            TextStyle(color: AppColors.textDark, fontSize: 18)),
                  );
                }

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
                    return _buildTicketDetallado(context, ordenes[index]);
                  },
                );
              },
            ),
    );
  }

  // 🔴 WIDGET DE TICKET DESPLEGABLE CON DESGLOSE
  Widget _buildTicketDetallado(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fecha =
        (data['fecha_hora'] as Timestamp?)?.toDate() ?? DateTime.now();
    final fechaFormateada = DateFormat('dd MMM yyyy - hh:mm a').format(fecha);

    final String estado = data['estado'].toString().toLowerCase();
    final double totalPagado = (data['total'] ?? 0).toDouble();

    // Desglose
    final double costoEnvio = 35.0;
    final double subtotal =
        totalPagado > costoEnvio ? (totalPagado - costoEnvio) : totalPagado;

    // Asignación de colores
    Color estadoColor = Colors.grey;
    if (estado == 'pendiente') estadoColor = Colors.orange;
    if (estado == 'preparando') estadoColor = Colors.blue;
    if (estado == 'enviado' || estado == 'entregado' || estado == 'completada')
      estadoColor = AppColors.successGreen;
    if (estado == 'cancelada') estadoColor = AppColors.errorRed;

    // 🔴 Recuperamos la lista de items guardada
    List<dynamic> items = data['items'] ?? [];

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.dividerLine),
      ),
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.ticket,
                      color: AppColors.primaryBrown),
                  const SizedBox(width: 8),
                  Text(
                    'Orden #${doc.id.substring(0, 5).toUpperCase()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  estado.toUpperCase(),
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(fechaFormateada,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          children: [
            Container(
              color: AppColors.backgroundBeige.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Detalle del Pedido',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Divider(color: AppColors.dividerLine),

                  // 🔴 LISTADO DE ARTÍCULOS
                  if (items.isNotEmpty)
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['cantidad'] ?? 1}x ${item['nombre_platillo'] ?? 'Platillo'}',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\$${(item['subtotal'] ?? 0).toDouble().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      );
                    }),

                  if (items.isEmpty)
                    const Text('Artículos no detallados en compras antiguas.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),

                  const SizedBox(height: 12),
                  const Divider(color: AppColors.textDark, thickness: 1),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text('\$${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Costo de Envío:',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text('\$${costoEnvio.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pagado:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '\$${totalPagado.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primaryBrown),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
