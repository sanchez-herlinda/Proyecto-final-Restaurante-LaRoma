import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../models/direccion_model.dart';

class DireccionesView extends StatelessWidget {
  const DireccionesView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().authState.data?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Mis Direcciones'),
        backgroundColor: AppColors.white,
      ),
      body: Consumer<PerfilProvider>(
        builder: (context, perfil, child) {
          if (perfil.direcciones.isEmpty) {
            return const Center(
                child: Text('No tienes direcciones guardadas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: perfil.direcciones.length,
            itemBuilder: (context, index) {
              final dir = perfil.direcciones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: AppColors.dividerLine),
                ),
                child: ListTile(
                  title: Text(dir.alias,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${dir.calleYNumero}, Col. ${dir.colonia}, CP ${dir.codigoPostal}\nRef: ${dir.indicaciones}'),
                  isThreeLine: dir.indicaciones.isNotEmpty,
                  leading: const Icon(Icons.location_on,
                      color: AppColors.primaryBrown),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrown,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => _mostrarDialogoAgregarDireccion(context, userId),
          child: const Text('Agregar nueva dirección',
              style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarDireccion(BuildContext context, String userId) {
    final aliasCtrl = TextEditingController();
    final calleCtrl = TextEditingController();
    final colCtrl = TextEditingController();
    final cpCtrl = TextEditingController();
    final refCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Nueva Dirección',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _crearInput(aliasCtrl, 'Alias (Ej: Casa)', Icons.bookmark_border),
              const SizedBox(height: 10),
              _crearInput(
                  calleCtrl, 'Calle y Número', Icons.location_on_outlined),
              const SizedBox(height: 10),
              _crearInput(colCtrl, 'Colonia', Icons.map_outlined),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _crearInput(
                          cpCtrl, 'C.P.', Icons.markunread_mailbox_outlined,
                          isNumber: true)),
                ],
              ),
              const SizedBox(height: 10),
              _crearInput(refCtrl, 'Indicaciones extra', Icons.info_outline),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textDark))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              if (aliasCtrl.text.isEmpty || calleCtrl.text.isEmpty) {
                return;
              }
              final d = Direccion(
                  id: '',
                  alias: aliasCtrl.text,
                  calleYNumero: calleCtrl.text,
                  colonia: colCtrl.text,
                  codigoPostal: cpCtrl.text,
                  indicaciones: refCtrl.text);
              await context.read<PerfilProvider>().agregarDireccion(userId, d);
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  Widget _crearInput(
      TextEditingController controller, String hint, IconData icon,
      {bool isNumber = false, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBrown, size: 20),
        filled: true,
        fillColor: AppColors.backgroundBeige.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }
}
