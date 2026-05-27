import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart'; // 🔴 Necesario para limpiar datos
import '../reservaciones/mis_reservaciones_view.dart';
import '../auth/login_view.dart';
import 'cuenta_view.dart';
import 'galeria_view.dart';
import 'direcciones_view.dart';
import 'metodos_pago_view.dart';

class AjustesView extends StatelessWidget {
  const AjustesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Ajustes',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 24)),
      ),
      body: Column(
        children: [
          _buildOpcion(context,
              icon: CupertinoIcons.person,
              title: 'Perfil',
              destino: const CuentaView()),
          const Divider(color: AppColors.dividerLine, height: 1),

          _buildOpcion(context,
              icon: CupertinoIcons.photo,
              title: 'Galeria',
              destino: const GaleriaView()),
          const Divider(color: AppColors.dividerLine, height: 1),

          _buildOpcion(context,
              icon: CupertinoIcons.location,
              title: 'Mis Direcciones',
              destino: const DireccionesView()),
          const Divider(color: AppColors.dividerLine, height: 1),

          _buildOpcion(context,
              icon: CupertinoIcons.creditcard,
              title: 'Métodos de Pago',
              destino: const MetodosPagoView()),
          const Divider(color: AppColors.dividerLine, height: 1),

          ListTile(
            leading:
                const Icon(Icons.calendar_month, color: AppColors.primaryBrown),
            title: const Text('Mis Reservaciones',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MisReservacionesView()),
              );
            },
          ),
          const Divider(color: AppColors.dividerLine, height: 1),

          // Opción de Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.errorRed),
            title: const Text('Cerrar Sesion',
                style: TextStyle(
                    color: AppColors.errorRed, fontWeight: FontWeight.bold)),
            onTap: () => _mostrarDialogoCerrarSesion(context),
          ),
          const Divider(color: AppColors.dividerLine, height: 1),
        ],
      ),
    );
  }

  Widget _buildOpcion(BuildContext context,
      {required IconData icon,
      required String title,
      required Widget destino}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destino));
      },
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: AppColors.white,
          title: const Text('Cerrar Sesion',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Estas seguro?', textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    // 🔴 LIMPIEZA TOTAL: Pasamos ambos providers
                    final auth = context.read<AuthProvider>();
                    final perfil = context.read<PerfilProvider>();

                    await auth.logout(perfil);

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Si'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('No'),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
