import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/carrito_provider.dart';

class PagoExitosoView extends StatelessWidget {
  const PagoExitosoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quita la flecha de regreso
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.errorRed),
            onPressed: () => _finalizar(context),
          )
        ],
        title: Text('La ROMA',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 24)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo Verde con Paloma
              Container(
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 5),
                ),
                padding: const EdgeInsets.all(30),
                child:
                    const Icon(Icons.check, size: 100, color: AppColors.white),
              ),
              const SizedBox(height: 40),

              Text(
                'Pago\nexitoso',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 60),

              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _finalizar(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finalizar(BuildContext context) {
    // 1. Limpiamos los datos del carrito
    context.read<CarritoProvider>().limpiarCarrito();
    // 2. Regresamos hasta la ruta principal (Dashboard)
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
