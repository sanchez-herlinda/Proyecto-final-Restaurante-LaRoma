import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PagoFallidoView extends StatelessWidget {
  const PagoFallidoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quitamos flecha predeterminada
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.errorRed, size: 28),
          onPressed: () => Navigator.pop(context), // Solo regresa al ticket
        ),
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
              // Círculo Rojo con X
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.errorRed,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child:
                    const Icon(Icons.close, size: 120, color: AppColors.white),
              ),
              const SizedBox(height: 40),

              Text(
                'Pago\nfallido',
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
