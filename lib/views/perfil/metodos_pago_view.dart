import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../models/tarjeta_model.dart';

class MetodosPagoView extends StatelessWidget {
  const MetodosPagoView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().authState.data?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
        backgroundColor: AppColors.white,
      ),
      body: Consumer<PerfilProvider>(
        builder: (context, perfil, child) {
          if (perfil.tarjetas.isEmpty) {
            return const Center(child: Text('No tienes tarjetas guardadas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: perfil.tarjetas.length,
            itemBuilder: (context, index) {
              final card = perfil.tarjetas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: AppColors.dividerLine),
                ),
                child: ListTile(
                  title: Text(card.numeroOculto,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                  subtitle: Text(card.nombreTitular),
                  leading: const Icon(Icons.credit_card,
                      color: AppColors.primaryBrown),

                  // 🔴 AQUÍ AGREGAMOS EL BOTÓN DE ELIMINAR TARJETA
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.errorRed),
                    onPressed: () =>
                        _confirmarEliminacion(context, userId, card.id),
                  ),
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
          onPressed: () => _mostrarDialogoAgregarTarjeta(context, userId),
          child: const Text('Agregar nueva tarjeta',
              style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // 🔴 DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR TARJETA
  void _confirmarEliminacion(BuildContext context, String userId, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarjeta',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta tarjeta de crédito/débito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textDark)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              await context.read<PerfilProvider>().eliminarTarjeta(userId, id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarTarjeta(BuildContext context, String userId) {
    final titularCtrl = TextEditingController();
    final numeroCtrl = TextEditingController();
    final vencCtrl = TextEditingController();
    final cvcCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Nueva Tarjeta',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _crearInput(
                  titularCtrl, 'Nombre del Titular', Icons.person_outline,
                  formatters: [LengthLimitingTextInputFormatter(40)]),
              const SizedBox(height: 10),
              _crearInput(numeroCtrl, 'Número de Tarjeta', Icons.credit_card,
                  isNumber: true,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ]),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _crearInput(vencCtrl, 'MMAA', Icons.calendar_today,
                          isNumber: true,
                          formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _crearInput(cvcCtrl, 'CVC', Icons.lock_outline,
                          isNumber: true,
                          isPassword: true,
                          formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ])),
                ],
              ),
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
              if (titularCtrl.text.isEmpty ||
                  numeroCtrl.text.length < 15 ||
                  vencCtrl.text.length < 4 ||
                  cvcCtrl.text.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tarjeta inválida. Revisa los campos.'),
                    backgroundColor: AppColors.errorRed));
                return;
              }
              String n = numeroCtrl.text.trim();
              final c = TarjetaBancaria(
                  id: '',
                  nombreTitular: titularCtrl.text,
                  numeroOculto:
                      '**** **** **** ${n.length >= 4 ? n.substring(n.length - 4) : n}',
                  numeroCompleto: n,
                  fechaVencimiento:
                      '${vencCtrl.text.substring(0, 2)}/${vencCtrl.text.substring(2)}',
                  cvc: cvcCtrl.text,
                  tipo: n.startsWith('4')
                      ? 'Visa'
                      : (n.startsWith('5') ? 'Mastercard' : 'Amex'));

              await context.read<PerfilProvider>().agregarTarjeta(userId, c);

              if (!context.mounted) return;
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
      {bool isNumber = false,
      bool isPassword = false,
      List<TextInputFormatter>? formatters}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      inputFormatters: formatters,
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
