import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/platillo_model.dart';
import '../../providers/carrito_provider.dart';

class PlatilloDetalleView extends StatelessWidget {
  final Platillo platillo;

  const PlatilloDetalleView({super.key, required this.platillo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        centerTitle: true,
        title: const Text(
          'La ROMA',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily:
                'Times New Roman', // Para dar ese toque elegante de tu diseño
          ),
        ),
      ),
      body: Column(
        children: [
          // SECCIÓN 1: Diseño del Fondo de 2 tonos y la imagen
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(height: 150, color: AppColors.backgroundBeige),
                    Container(height: 100, color: AppColors.white),
                  ],
                ),
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Hero(
                      // Animación fluida si vienes de la lista
                      tag: platillo.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          platillo.imagenUrl,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              size: 100,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SECCIÓN 2: Información del Platillo
          const SizedBox(height: 10),
          Text(
            platillo.nombre,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              platillo.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '\$${platillo.precio.toInt()}',
            style: const TextStyle(
                fontSize: 32,
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.w500),
          ),

          const Spacer(),

          // SECCIÓN 3: Botones (Comprar y Agregar al Carrito)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.primaryBrown, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Solo agregar silenciosamente
                    context.read<CarritoProvider>().agregarPlatillo(platillo);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${platillo.nombre} agregado al carrito'),
                      backgroundColor: AppColors.successGreen,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: const Text('Agregar al carrito',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
