import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/sucursales_provider.dart';
import 'pago_view.dart';

class CarritoView extends StatelessWidget {
  const CarritoView({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final sucursal = context.watch<SucursalesProvider>().sucursalSeleccionada;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Mi Orden'),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: AppColors.errorRed),
            onPressed: carrito.items.isEmpty
                ? null
                : () => _confirmarLimpiar(context, carrito),
          )
        ],
      ),
      body: carrito.items.isEmpty
          ? const Center(
              child: Text('Tu carrito está vacío',
                  style: TextStyle(fontSize: 18, color: AppColors.textDark)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: carrito.items.length,
                    itemBuilder: (context, index) {
                      final item = carrito.items[index];
                      return Card(
                        color: AppColors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CachedNetworkImage(
                                  imageUrl: item.platillo.imagenUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.fastfood),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.platillo.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text('\$${item.platillo.precio.toInt()}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: AppColors.primaryBrown),
                                    onPressed: () => carrito
                                        .removerPlatillo(item.platillo.id),
                                  ),
                                  Text('${item.cantidad}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: AppColors.primaryBrown),
                                    onPressed: () =>
                                        carrito.agregarPlatillo(item.platillo),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // --- BARRA INFERIOR ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border:
                        Border(top: BorderSide(color: AppColors.dividerLine)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('\$${carrito.total.toInt()}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // 🔴 BOTÓN 1: SUCURSAL (AHORA ABRE EL SELECTOR DIRECTO)
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.storefront, size: 18),
                              label: Text(
                                sucursal != null
                                    ? sucursal.nombre
                                    : 'Elegir Sucursal',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: sucursal != null
                                    ? AppColors.successGreen
                                    : AppColors.errorRed,
                                side: BorderSide(
                                    color: sucursal != null
                                        ? AppColors.successGreen
                                        : AppColors.errorRed),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () =>
                                  _mostrarSelectorSucursales(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // BOTÓN 2: PAGAR
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12)),
                              onPressed:
                                  sucursal == null || carrito.items.isEmpty
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PagoView()),
                                          );
                                        },
                              child: const Text('Ir a pagar',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // 🔴 NUEVA FUNCIÓN: Abre un menú inferior para elegir sucursal rápidamente
  void _mostrarSelectorSucursales(BuildContext context) {
    final sucursalesProv = context.read<SucursalesProvider>();
    final sucursalesDisponibles =
        sucursalesProv.sucursales.where((s) => s.disponible).toList();

    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Selecciona una Sucursal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1, color: AppColors.dividerLine),
                if (sucursalesDisponibles.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                          'No hay sucursales disponibles en este momento.'))
                else
                  ...sucursalesDisponibles.map((sucursal) => ListTile(
                        leading: const Icon(Icons.storefront,
                            color: AppColors.primaryBrown),
                        title: Text(sucursal.nombre,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(sucursal.direccion),
                        onTap: () {
                          sucursalesProv.seleccionarSucursal(sucursal);
                          Navigator.pop(context); // Cierra el menú inferior
                        },
                      )),
              ],
            ),
          );
        });
  }

  void _confirmarLimpiar(BuildContext context, CarritoProvider carrito) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar todos los productos?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () {
              carrito.limpiarCarrito();
              Navigator.pop(context);
            },
            child: const Text('Vaciar'),
          )
        ],
      ),
    );
  }
}
