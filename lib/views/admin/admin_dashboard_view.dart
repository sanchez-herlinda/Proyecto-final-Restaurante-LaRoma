import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import '../home/dashboard_view.dart';
import '../../providers/perfil_provider.dart';
import 'admin_platillos_view.dart';
import 'admin_ordenes_view.dart';
import 'admin_usuarios_view.dart';
import 'admin_sucursales_view.dart';
import 'admin_ingredientes_view.dart';
import 'admin_proveedores_view.dart';
import 'admin_mesas_view.dart';
import 'admin_reservaciones_view.dart';
import 'admin_direcciones_view.dart'; // 🔴 NUEVO
import 'admin_metodos_pago_view.dart'; // 🔴 NUEVO

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _indiceSeleccionado = 0;

  final List<Widget> _vistasAdmin = [
    const AdminPlatillosView(), // 0
    const AdminOrdenesView(), // 1
    const AdminUsuariosView(), // 2
    const AdminSucursalesView(), // 3
    const AdminIngredientesView(), // 4
    const AdminProveedoresView(), // 5
    const AdminMesasView(), // 6
    const AdminReservacionesView(), // 7
    const AdminDireccionesView(), // 8 🔴
    const AdminMetodosPagoView(), // 9 🔴
  ];

  final List<String> _titulos = [
    'Gestión de Menú',
    'Gestión de Órdenes',
    'Gestión de Usuarios',
    'Gestión de Sucursales',
    'Inventario (Ingredientes)',
    'Proveedores',
    'Control de Salón (Mesas)',
    'Planificación (Reservas)',
    'Direcciones Globales', // 🔴
    'Métodos de Pago Globales' // 🔴
  ];

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().authState.data;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: Text(_titulos[_indiceSeleccionado],
            style: const TextStyle(color: AppColors.textDark, fontSize: 18)),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration:
                        const BoxDecoration(color: AppColors.primaryBrown),
                    accountName: Text(usuario?.nombre ?? 'Administrador',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    accountEmail: Text(usuario?.email ?? ''),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.admin_panel_settings,
                          size: 40, color: AppColors.primaryBrown),
                    ),
                  ),
                  _buildDrawerItem(
                      icon: Icons.restaurant_menu,
                      title: 'Menú / Platillos',
                      index: 0),
                  _buildDrawerItem(
                      icon: Icons.receipt_long,
                      title: 'Órdenes Activas',
                      index: 1),
                  _buildDrawerItem(
                      icon: Icons.people,
                      title: 'Usuarios / Empleados',
                      index: 2),
                  _buildDrawerItem(
                      icon: Icons.storefront, title: 'Sucursales', index: 3),

                  const Divider(color: AppColors.dividerLine),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text('DATOS DE CLIENTES',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  _buildDrawerItem(
                      icon: Icons.location_on,
                      title: 'Direcciones',
                      index: 8), // 🔴
                  _buildDrawerItem(
                      icon: Icons.credit_card,
                      title: 'Métodos de Pago',
                      index: 9), // 🔴

                  const Divider(color: AppColors.dividerLine),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text('RECEPCIÓN Y SALÓN',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  _buildDrawerItem(
                      icon: Icons.table_restaurant,
                      title: 'Mesas del Salón',
                      index: 6),
                  _buildDrawerItem(
                      icon: Icons.calendar_month,
                      title: 'Reservaciones',
                      index: 7),

                  const Divider(color: AppColors.dividerLine),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text('INVENTARIO',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  _buildDrawerItem(
                      icon: Icons.kitchen, title: 'Ingredientes', index: 4),
                  _buildDrawerItem(
                      icon: Icons.local_shipping,
                      title: 'Proveedores',
                      index: 5),

                  const Divider(color: AppColors.dividerLine),
                  ListTile(
                    leading:
                        const Icon(Icons.store, color: AppColors.successGreen),
                    title: const Text('Ir a la Tienda (Cliente)',
                        style: TextStyle(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashboardView()));
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.dividerLine, height: 1),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: AppColors.errorRed),
              title: const Text('Cerrar Sesión',
                  style: TextStyle(
                      color: AppColors.errorRed, fontWeight: FontWeight.bold)),
              // En cualquier botón de Logout que tengas en la app
              onTap: () async {
                // Pasamos ambos providers
                final auth = context.read<AuthProvider>();
                final perfil = context.read<PerfilProvider>();

                await auth.logout(perfil); // 🔴 Ahora el logout limpia ambos

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _vistasAdmin[_indiceSeleccionado],
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon, required String title, required int index}) {
    final isSelected = _indiceSeleccionado == index;
    return ListTile(
      dense: true,
      leading: Icon(icon,
          color: isSelected ? AppColors.primaryBrown : AppColors.textDark),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryBrown : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.backgroundBeige,
      onTap: () {
        setState(() => _indiceSeleccionado = index);
        Navigator.pop(context);
      },
    );
  }
}
