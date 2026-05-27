import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/menu_provider.dart';

class GaleriaView extends StatelessWidget {
  const GaleriaView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del menú que ya descargó todos los platillos
    final menuState = context.watch<MenuProvider>().menuState;

    // Obtenemos la lista de platillos
    final platillos = menuState.data ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Galería La ROMA'),
        backgroundColor: AppColors.white,
      ),
      body: menuState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrown))
          : platillos.isEmpty
              ? const Center(
                  child: Text('No hay imágenes disponibles en este momento.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 imágenes por fila como en Instagram
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: platillos.length,
                  itemBuilder: (context, index) {
                    final platillo = platillos[index];

                    return GestureDetector(
                      onTap: () => _mostrarImagenCompleta(
                          context, platillo.imagenUrl, platillo.nombre),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: platillo.imagenUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                                child: Icon(Icons.image, color: Colors.grey)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Pequeño extra: Al tocar una imagen, se abre en grande
  void _mostrarImagenCompleta(BuildContext context, String url, String nombre) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              nombre,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}
