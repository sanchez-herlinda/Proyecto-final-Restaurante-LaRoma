import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'categoria_filtrada_view.dart';

class CategoriasView extends StatelessWidget {
  const CategoriasView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categoriasInfo = [
      {'nombre': 'Aperitivos', 'icono': Icons.tapas},
      {'nombre': 'Primeros', 'icono': Icons.ramen_dining},
      {'nombre': 'Segundos', 'icono': Icons.set_meal},
      {'nombre': 'Guarniciones', 'icono': Icons.eco},
      {'nombre': 'Postres', 'icono': Icons.cake},
      {'nombre': 'Bebidas', 'icono': Icons.local_bar},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('La ROMA',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Nuestro Menú',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 28),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoriasInfo.length,
              itemBuilder: (context, index) {
                final categoria = categoriasInfo[index]['nombre'];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.dividerLine),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(categoriasInfo[index]['icono'],
                          color: AppColors.primaryBrown),
                    ),
                    title: Text(
                      categoria,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_right,
                        size: 20, color: AppColors.textDark),
                    onTap: () {
                      // 🔴 AQUÍ ESTÁ LA CORRECCIÓN: usamos nombreCategoria
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoriaFiltradaView(nombreCategoria: categoria),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
