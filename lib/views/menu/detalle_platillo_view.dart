import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/platillo_model.dart';
import 'package:provider/provider.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/menu_provider.dart'; // 🔴 IMPORTANTE PARA LEER LA LISTA DE PLATILLOS

class DetallePlatilloView extends StatefulWidget {
  final Platillo platillo;

  const DetallePlatilloView({super.key, required this.platillo});

  @override
  State<DetallePlatilloView> createState() => _DetallePlatilloViewState();
}

class _DetallePlatilloViewState extends State<DetallePlatilloView> {
  // Variable de estado que guarda el platillo que se está mostrando actualmente
  late Platillo _platilloActual;

  @override
  void initState() {
    super.initState();
    _platilloActual = widget.platillo;
  }

  // 🔴 FUNCIÓN PARA CAMBIAR DE PLATILLO CON LAS FLECHAS
  void _cambiarPlatillo(int direccion) {
    final menuLista = context.read<MenuProvider>().menuState.data;
    if (menuLista == null || menuLista.isEmpty) return;

    // Buscamos en qué posición de la lista global está el platillo actual
    int indexActual = menuLista.indexWhere((p) => p.id == _platilloActual.id);
    if (indexActual == -1) return;

    // Calculamos la nueva posición sumando o restando (direccion será +1 o -1)
    int nuevoIndex = indexActual + direccion;

    // Si nos pasamos del inicio, saltamos al final (efecto bucle)
    if (nuevoIndex < 0) {
      nuevoIndex = menuLista.length - 1;
    }
    // Si nos pasamos del final, regresamos al inicio (efecto bucle)
    else if (nuevoIndex >= menuLista.length) {
      nuevoIndex = 0;
    }

    // Actualizamos la pantalla con el nuevo platillo
    setState(() {
      _platilloActual = menuLista[nuevoIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'La ROMA',
          style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recomendaciones',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 30),

            // Carrusel / Imagen principal (Con flechas FUNCIONALES)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔴 FLECHA IZQUIERDA
                GestureDetector(
                  onTap: () => _cambiarPlatillo(-1), // Retrocede 1 lugar
                  child: const Icon(CupertinoIcons.chevron_left,
                      color: AppColors.textDark, size: 30),
                ),
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBeige,
                    border: Border.all(color: AppColors.dividerLine),
                  ),
                  child: CachedNetworkImage(
                    key: ValueKey(_platilloActual
                        .id), // Hace que la imagen recargue animada al cambiar
                    imageUrl: _platilloActual
                        .imagenUrl, // Usamos la variable de estado
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CupertinoActivityIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 50),
                  ),
                ),
                // 🔴 FLECHA DERECHA
                GestureDetector(
                  onTap: () => _cambiarPlatillo(1), // Avanza 1 lugar
                  child: const Icon(CupertinoIcons.chevron_right,
                      color: AppColors.textDark, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return const Icon(Icons.star, color: Colors.amber, size: 28);
              }),
            ),
            const SizedBox(height: 20),

            // Nombre del platillo (Usando estado)
            Text(
              _platilloActual.nombre,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),

            // Descripción (Usando estado)
            Text(
              _platilloActual.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Precio (Usando estado)
            Text(
              '\$${_platilloActual.precio.toInt()}',
              style: const TextStyle(
                  fontSize: 22,
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Botón Agregar al Carrito (Usando estado)
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  // Guardamos el platillo actual en el carrito
                  context
                      .read<CarritoProvider>()
                      .agregarPlatillo(_platilloActual);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${_platilloActual.nombre} agregado al carrito'),
                      backgroundColor: AppColors.successGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Agregar a carrito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
