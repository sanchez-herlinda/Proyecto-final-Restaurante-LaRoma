import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../models/direccion_model.dart';
import '../../models/tarjeta_model.dart';
import 'pago_exitoso_view.dart';

class PagoView extends StatefulWidget {
  const PagoView({super.key});

  @override
  State<PagoView> createState() => _PagoViewState();
}

class _PagoViewState extends State<PagoView> {
  Direccion? _direccionSeleccionada;
  TarjetaBancaria? _tarjetaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final authState = context.watch<AuthProvider>().authState;
    final userId = authState.data?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
          title: const Text('Checkout'), backgroundColor: AppColors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ClipPath(
              clipper: TicketClipper(),
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(24),
                child: Consumer<PerfilProvider>(
                  builder: (context, perfil, child) {
                    // Resolución segura para que DropdownButton no rompa si cambia la lista
                    Direccion? direccionSegura =
                        perfil.direcciones.contains(_direccionSeleccionada)
                            ? _direccionSeleccionada
                            : (perfil.direcciones.isNotEmpty
                                ? perfil.direcciones.first
                                : null);

                    TarjetaBancaria? tarjetaSegura =
                        perfil.tarjetas.contains(_tarjetaSeleccionada)
                            ? _tarjetaSeleccionada
                            : (perfil.tarjetas.isNotEmpty
                                ? perfil.tarjetas.first
                                : null);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('La ROMA',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 24)),
                        const Divider(color: AppColors.textDark),
                        const Text('Enviar a:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<Direccion>(
                                isExpanded: true,
                                value: direccionSegura,
                                hint: const Text("Seleccionar dirección"),
                                items: perfil.direcciones.map((dir) {
                                  return DropdownMenuItem(
                                      value: dir,
                                      child: Text(
                                          "${dir.alias}: ${dir.calleYNumero}"));
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _direccionSeleccionada = val;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.primaryBrown),
                              onPressed: () => _mostrarDialogoAgregarDireccion(
                                  context, userId),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Pagar con:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<TarjetaBancaria>(
                                isExpanded: true,
                                value: tarjetaSegura,
                                hint: const Text("Seleccionar método de pago"),
                                items: perfil.tarjetas.map((card) {
                                  return DropdownMenuItem(
                                      value: card,
                                      child: Text(card.numeroOculto));
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _tarjetaSeleccionada = val;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.primaryBrown),
                              onPressed: () => _mostrarDialogoAgregarTarjeta(
                                  context, userId),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.textDark),
                        ...carrito.items.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${item.cantidad}x ${item.platillo.nombre}'),
                                  Text('\$${item.subtotal.toInt()}')
                                ],
                              ),
                            )),
                        const Divider(color: AppColors.textDark),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('\$${carrito.total.toInt()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<PerfilProvider>(builder: (context, perfil, child) {
              // Validación para habilitar o deshabilitar el botón
              bool canPay =
                  perfil.direcciones.isNotEmpty && perfil.tarjetas.isNotEmpty;
              return ElevatedButton(
                onPressed: canPay
                    ? () => _confirmarPago(context, userId, carrito)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text('Confirmar y pagar orden'),
              );
            }),
          ],
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
                  titularCtrl, 'Nombre del Titular', Icons.person_outline),
              const SizedBox(height: 10),
              _crearInput(numeroCtrl, 'Número de Tarjeta', Icons.credit_card,
                  isNumber: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _crearInput(
                          vencCtrl, 'MM/AA', Icons.calendar_today,
                          isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _crearInput(cvcCtrl, 'CVC', Icons.lock_outline,
                          isNumber: true, isPassword: true)),
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
                  numeroCtrl.text.isEmpty ||
                  cvcCtrl.text.isEmpty) {
                return;
              }
              String n = numeroCtrl.text.trim();
              final c = TarjetaBancaria(
                  id: '',
                  nombreTitular: titularCtrl.text,
                  numeroOculto:
                      '**** **** **** ${n.length >= 4 ? n.substring(n.length - 4) : n}',
                  numeroCompleto: n,
                  fechaVencimiento: vencCtrl.text,
                  cvc: cvcCtrl.text,
                  tipo: n.startsWith('4') ? 'Visa' : 'Mastercard');
              await context.read<PerfilProvider>().agregarTarjeta(userId, c);

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

  void _confirmarPago(
      BuildContext context, String userId, CarritoProvider carrito) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await carrito.procesarPago(userId);

      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const PagoExitosoView()));
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    double x = 0;
    double y = size.height;
    double increment = size.width / 20;
    while (x < size.width) {
      x += increment / 2;
      y = y == size.height ? size.height - 15 : size.height;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
