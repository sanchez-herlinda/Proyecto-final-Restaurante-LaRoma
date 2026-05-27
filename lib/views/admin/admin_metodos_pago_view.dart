import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tarjeta_model.dart';

class AdminMetodosPagoView extends StatelessWidget {
  const AdminMetodosPagoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        // Nota: Asegúrate de que el nombre coincida con tu Firebase ('tarjetas' o 'tarjeta')
        stream:
            FirebaseFirestore.instance.collectionGroup('tarjetas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No hay métodos de pago registrados.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final card = TarjetaBancaria.fromJson(
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
                        Icon(Icons.credit_card, color: AppColors.primaryBrown),
                  ),
                  title: Text(card.numeroOculto,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                  subtitle: Text(
                      'Titular: ${card.nombreTitular}\nVence: ${card.fechaVencimiento} - CVC: ***'),
                  isThreeLine: true,
                  trailing: Text(card.tipo.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                  onTap: () => _mostrarConfirmacionEliminar(context,
                      docReference: doc.reference, tarjeta: card),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // En el caso de las tarjetas, por seguridad, un administrador no debería editarlas, solo eliminarlas.
  void _mostrarConfirmacionEliminar(BuildContext context,
      {required DocumentReference docReference,
      required TarjetaBancaria tarjeta}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Método de Pago'),
        content: Text(
            '¿Deseas eliminar la tarjeta terminación ${tarjeta.numeroOculto} de la base de datos?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textDark))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              await docReference.delete();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Tarjeta eliminada con éxito'),
                    backgroundColor: AppColors.errorRed),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
