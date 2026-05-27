import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sucursales_provider.dart';
import 'package:intl/intl.dart';

class CrearReservacionView extends StatefulWidget {
  const CrearReservacionView({super.key});

  @override
  State<CrearReservacionView> createState() => _CrearReservacionViewState();
}

class _CrearReservacionViewState extends State<CrearReservacionView> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  final _personasCtrl = TextEditingController(text: '2');
  final _notasCtrl = TextEditingController();

  Future<void> _seleccionarFecha() async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBrown,
              onPrimary: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (seleccion != null) {
      setState(() => _fechaSeleccionada = seleccion);
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? seleccion = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBrown,
              onPrimary: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (seleccion != null) {
      setState(() => _horaSeleccionada = seleccion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sucursal = context.watch<SucursalesProvider>().sucursalSeleccionada;
    final userId = context.watch<AuthProvider>().authState.data?.id;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Reservar Mesa'),
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.table_restaurant,
                size: 60, color: AppColors.primaryBrown),
            const SizedBox(height: 16),
            Text('Planifica tu visita',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 24)),
            const SizedBox(height: 24),

            // Sucursal actual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.dividerLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sucursal seleccionada:',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    sucursal != null
                        ? sucursal.nombre
                        : 'Ninguna (Ve a Ubicaciones primero)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sucursal != null
                          ? AppColors.textDark
                          : AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fecha y Hora
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.textDark,
                        alignment: Alignment.centerLeft),
                    icon: const Icon(Icons.calendar_month,
                        color: AppColors.primaryBrown),
                    label: Text(_fechaSeleccionada == null
                        ? 'Elegir Fecha'
                        : DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)),
                    onPressed: _seleccionarFecha,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.textDark,
                        alignment: Alignment.centerLeft),
                    icon: const Icon(Icons.access_time,
                        color: AppColors.primaryBrown),
                    label: Text(_horaSeleccionada == null
                        ? 'Elegir Hora'
                        : _horaSeleccionada!.format(context)),
                    onPressed: _seleccionarHora,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Personas
            TextField(
              controller: _personasCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de Personas',
                prefixIcon:
                    const Icon(Icons.people, color: AppColors.primaryBrown),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Notas
            TextField(
              controller: _notasCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText:
                    'Notas especiales (Ej: Aniversario, Cerca de la ventana)',
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: (sucursal == null ||
                      _fechaSeleccionada == null ||
                      _horaSeleccionada == null ||
                      userId == null)
                  ? null
                  : () async {
                      // Crear el DateTime combinado
                      final fechaHoraCombinada = DateTime(
                        _fechaSeleccionada!.year,
                        _fechaSeleccionada!.month,
                        _fechaSeleccionada!.day,
                        _horaSeleccionada!.hour,
                        _horaSeleccionada!.minute,
                      );

                      final data = {
                        'cliente_id': userId,
                        'sucursal_id': sucursal.id,
                        'mesa_id': '', // El admin la asignará
                        'fecha_hora': Timestamp.fromDate(fechaHoraCombinada),
                        'num_personas': int.tryParse(_personasCtrl.text) ?? 2,
                        'estado': 'pendiente',
                        'notas': _notasCtrl.text.trim(),
                      };

                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) =>
                              const Center(child: CircularProgressIndicator()));

                      await FirebaseFirestore.instance
                          .collection('reservacion')
                          .add(data);

                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context); // Cierra loader
                      Navigator.pop(context); // Regresa a la pantalla anterior

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                '¡Reservación enviada! El restaurante confirmará tu mesa pronto.'),
                            backgroundColor: AppColors.successGreen),
                      );
                    },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Confirmar Solicitud de Reserva',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
