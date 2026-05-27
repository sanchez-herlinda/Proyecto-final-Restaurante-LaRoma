import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/menu_provider.dart';
import 'detalle_platillo_view.dart';

class CategoriaFiltradaView extends StatefulWidget {
  final String nombreCategoria;
  const CategoriaFiltradaView({super.key, required this.nombreCategoria});

  @override
  State<CategoriaFiltradaView> createState() => _CategoriaFiltradaViewState();
}

class _CategoriaFiltradaViewState extends State<CategoriaFiltradaView> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final menuState = context.watch<MenuProvider>().menuState;

    // 🔴 FILTRAMOS POR CATEGORÍA Y LUEGO POR LO QUE ESCRIBA EL USUARIO
    // 🔴 FILTRAMOS POR CATEGORÍA Y LUEGO POR LO QUE ESCRIBA EL USUARIO
    final platillosFiltrados = menuState.data?.where((platillo) {
          final coincideCategoria = platillo.categoriaId.toLowerCase() ==
              widget.nombreCategoria.toLowerCase();
          final coincideBusqueda =
              platillo.nombre.toLowerCase().contains(_busqueda.toLowerCase());

          // Usamos ambas variables para quitar la alerta y hacer el filtro real
          return coincideCategoria && coincideBusqueda;
        }).toList() ??
        [];
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.pop(context)),
        title: Text('La ROMA',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 24)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔴 BUSCADOR FUNCIONAL
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.textDark)),
              child: TextField(
                onChanged: (valor) {
                  setState(() {
                    _busqueda = valor;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar platillo...',
                  prefixIcon:
                      Icon(CupertinoIcons.search, color: AppColors.textDark),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(widget.nombreCategoria,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 24)),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: menuState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : platillosFiltrados.isEmpty
                    ? const Center(child: Text('No se encontraron platillos.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: platillosFiltrados.length,
                        itemBuilder: (context, index) {
                          final platillo = platillosFiltrados[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetallePlatilloView(
                                          platillo: platillo)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundBeige
                                    .withValues(alpha: 0.5),
                                border: Border.all(
                                    color: AppColors.dividerLine
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CachedNetworkImage(
                                      imageUrl: platillo.imagenUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (c, u, e) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Text(platillo.nombre,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                ],
                              ),
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
