import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../models/platillo_model.dart';
import '../menu/categorias_view.dart';
import '../menu/detalle_platillo_view.dart'; // 🔴 Apunta a la vista de flechas original
import '../perfil/cuenta_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _busqueda = '';

  // Controlador para el Carrusel de Imágenes
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // URLs de ejemplo para el carrusel
  final List<String> _imagenesCarrusel = [
    'https://raw.githubusercontent.com/sanchez-herlinda/Imagenes_para_Flutter_6J-11-Feb-2026/refs/heads/main/calzone.png',
    'https://raw.githubusercontent.com/sanchez-herlinda/Imagenes_para_Flutter_6J-11-Feb-2026/refs/heads/main/focc.png',
    'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&q=80&w=1000',
    'https://raw.githubusercontent.com/sanchez-herlinda/Imagenes_para_Flutter_6J-11-Feb-2026/refs/heads/main/gelato.png',
    'https://raw.githubusercontent.com/sanchez-herlinda/Imagenes_para_Flutter_6J-11-Feb-2026/refs/heads/main/pizza1.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = context.watch<MenuProvider>().menuState;

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
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
          ),

          // Carrusel (Se oculta si el usuario empieza a escribir en el buscador)
          if (_busqueda.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _imagenesCarrusel.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: _imagenesCarrusel[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CupertinoActivityIndicator()),
                          errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundBeige,
                              child: const Icon(Icons.error)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          if (_busqueda.isEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _busqueda.isEmpty ? 'Nuestro Menú' : 'Resultados de búsqueda',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Times New Roman'),
              ),
            ),
          ),

          menuState.isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBrown),
                )))
              : platillosFiltrados.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No se encontró ningún platillo.'),
                    )))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildPlatilloCard(
                              context, platillosFiltrados[index]),
                          childCount: platillosFiltrados.length,
                        ),
                      ),
                    ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildPlatilloCard(BuildContext context, Platillo platillo) {
    return GestureDetector(
      onTap: () {
        // 🔴 NAVEGAR A LA VISTA ORIGINAL CON FLECHAS
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
              child: Hero(
                tag: platillo.id,
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
