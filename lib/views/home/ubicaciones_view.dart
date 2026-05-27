import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/sucursales_provider.dart';
import '../reservaciones/crear_reservacion_view.dart'; // 🔴 IMPORTAMOS LA VISTA DE RESERVA

class UbicacionesView extends StatefulWidget {
  const UbicacionesView({super.key});

  @override
  State<UbicacionesView> createState() => _UbicacionesViewState();
}

class _UbicacionesViewState extends State<UbicacionesView> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final sucursalesProv = context.watch<SucursalesProvider>();

    final sucursalesFiltradas = sucursalesProv.sucursales.where((s) {
      return s.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          s.direccion.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Sucursales')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  hintText: 'Buscar sucursal...',
                  prefixIcon:
                      Icon(CupertinoIcons.search, color: AppColors.textDark),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: sucursalesFiltradas.isEmpty
                ? const Center(child: Text('No se encontraron sucursales.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: sucursalesFiltradas.length,
                    itemBuilder: (context, index) {
                      final sucursal = sucursalesFiltradas[index];
                      final bool isSelected =
                          sucursalesProv.sucursalSeleccionada?.id ==
                              sucursal.id;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? AppColors.successGreen
                                : AppColors.dividerLine,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected
                              ? AppColors.successGreen.withValues(alpha: 0.05)
                              : AppColors.backgroundBeige
                                  .withValues(alpha: 0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(sucursal.nombre,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 8),
                                        Text(
                                            'Dirección:\n${sucursal.direccion}',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 8),
                                        Text('Horario:\n${sucursal.horario}',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // 🔴 FILA DE BOTONES ACTUALIZADA
                              Row(
                                children: [
                                  // Botón 1: Seleccionar para Pick-up
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: sucursal.disponible
                                          ? () {
                                              sucursalesProv
                                                  .seleccionarSucursal(
                                                      sucursal);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Elegida para recoger pedido: ${sucursal.nombre}')));
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected
                                              ? AppColors.successGreen
                                              : AppColors.textDark),
                                      child: Text(isSelected
                                          ? 'Elegida'
                                          : 'Elegir Local'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 🔴 Botón 2: Reservar Mesa (NUEVO)
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: sucursal.disponible
                                          ? () {
                                              // Al darle a reservar, primero seleccionamos la sucursal por defecto
                                              sucursalesProv
                                                  .seleccionarSucursal(
                                                      sucursal);
                                              // Y luego abrimos el formulario de reserva
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const CrearReservacionView()));
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBrown),
                                      child: const Text('Reservar Mesa'),
                                    ),
                                  ),
                                ],
                              ),
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
