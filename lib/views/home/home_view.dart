import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../models/platillo_model.dart';
import '../menu/categorias_view.dart';
import '../menu/detalle_platillo_view.dart';
import '../perfil/cuenta_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final menuState = context.watch<MenuProvider>().menuState;

    // 🔴 FILTRAMOS LA LISTA GLOBAL SEGÚN EL BUSCADOR
    final platillosFiltrados = menuState.data?.where((platillo) {
          return platillo.nombre
              .toLowerCase()
              .contains(_busqueda.toLowerCase());
        }).toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Abre la vista de Categorías
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoriasView()),
            );
          },
        ),
        title: Text('La ROMA',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 24)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CuentaView()),
              );
              // Navegar al perfil
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- BUSCADOR FUNCIONAL ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundBeige.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.textDark),
              ),
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

          // --- LISTA DE PLATILLOS ---
          Expanded(
            child: menuState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBrown))
                : platillosFiltrados.isEmpty
                    ? const Center(
                        child: Text('No se encontró ningún platillo.'))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              2, // Dos columnas como en tu diseño inicial
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: platillosFiltrados.length,
                        itemBuilder: (context, index) {
                          return _buildPlatilloCard(
                              context, platillosFiltrados[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Widget para las tarjetas de platillos
  Widget _buildPlatilloCard(BuildContext context, Platillo platillo) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallePlatilloView(platillo: platillo),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundBeige.withValues(alpha: 0.7),
          border:
              Border.all(color: AppColors.dividerLine.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: platillo.imagenUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CupertinoActivityIndicator()),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platillo.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('\$${platillo.precio.toInt()}'),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_outlined,
                      size: 20, color: AppColors.textDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
