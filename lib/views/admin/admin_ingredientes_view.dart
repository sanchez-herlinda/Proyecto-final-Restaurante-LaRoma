import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/inventario_model.dart';

class AdminIngredientesView extends StatelessWidget {
  const AdminIngredientesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('ingrediente').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No hay ingredientes registrados.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final ing = Ingrediente.fromJson(
                  docs[index].data() as Map<String, dynamic>, docs[index].id);

              // 🔴 LÓGICA DE ALERTA DE STOCK BAJO
              final bool alertaStock = ing.stockActual <= ing.stockMinimo;

              return Card(
                color: alertaStock
                    ? AppColors.errorRed.withValues(alpha: 0.1)
                    : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                      color: alertaStock
                          ? AppColors.errorRed
                          : AppColors.dividerLine),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    alertaStock ? Icons.warning_amber_rounded : Icons.kitchen,
                    color: alertaStock
                        ? AppColors.errorRed
                        : AppColors.primaryBrown,
                    size: 32,
                  ),
                  title: Text(ing.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Stock: ${ing.stockActual} ${ing.unidadMedida}\nMínimo: ${ing.stockMinimo} ${ing.unidadMedida}'),
                  isThreeLine: true,
                  trailing: Text('\$${ing.costoUnitario}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  onTap: () => _mostrarFormulario(context, ingrediente: ing),
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

  void _mostrarFormulario(BuildContext context, {Ingrediente? ingrediente}) {
    final bool isEditing = ingrediente != null;

    final nombreCtrl = TextEditingController(text: ingrediente?.nombre ?? '');
    final unidadCtrl =
        TextEditingController(text: ingrediente?.unidadMedida ?? '');
    final actualCtrl =
        TextEditingController(text: ingrediente?.stockActual.toString() ?? '');
    final minimoCtrl =
        TextEditingController(text: ingrediente?.stockMinimo.toString() ?? '');
    final costoCtrl = TextEditingController(
        text: ingrediente?.costoUnitario.toString() ?? '');
    bool isActivo = ingrediente?.activo ?? true;

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
                  Text(isEditing ? 'Editar Ingrediente' : 'Nuevo Ingrediente',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre (Ej: Tomate)')),
                  TextField(
                      controller: unidadCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Unidad (Ej: kg, lts, pzas)')),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: actualCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Stock Actual'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextField(
                              controller: minimoCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Stock Mínimo'))),
                    ],
                  ),
                  TextField(
                      controller: costoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Costo Unitario (\$)')),
                  SwitchListTile(
                    title: const Text('Ingrediente Activo'),
                    activeThumbColor: AppColors.primaryBrown,
                    value: isActivo,
                    onChanged: (val) => setModalState(() => isActivo = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (nombreCtrl.text.isEmpty) return;
                      final data = {
                        'nombre': nombreCtrl.text.trim(),
                        'unidad_medida': unidadCtrl.text.trim(),
                        'stock_actual': double.tryParse(actualCtrl.text) ?? 0.0,
                        'stock_minimo': double.tryParse(minimoCtrl.text) ?? 0.0,
                        'costo_unitario':
                            double.tryParse(costoCtrl.text) ?? 0.0,
                        'activo': isActivo,
                      };
                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('ingrediente')
                            .doc(ingrediente.id)
                            .update(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('ingrediente')
                            .add(data);
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                  if (isEditing) ...[
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('ingrediente')
                            .doc(ingrediente.id)
                            .delete();
                        if (!context.mounted) return;
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
