import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home_view.dart';
import '../carrito/carrito_view.dart';
import 'ubicaciones_view.dart';
import 'historial_tickets_view.dart';
import '../perfil/ajustes_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  // Aquí pondremos las 5 pantallas que corresponden a la barra inferior
  final List<Widget> _pantallas = [
    const HomeView(), // Placeholder
    const CarritoView(), // Placeholder
    const UbicacionesView(), // Placeholder
    const HistorialTicketsView(),
    const AjustesView() // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: _pantallas[_currentIndex],

      // La barra de navegación inferior idéntica al Figma
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: AppColors.dividerLine,
                  width: 1)), // Línea divisoria superior
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.white,
          type: BottomNavigationBarType
              .fixed, // Mantiene los íconos estáticos sin animación extraña
          selectedItemColor: AppColors.primaryBrown,
          unselectedItemColor: AppColors.textDark,
          showSelectedLabels: false, // En tu Figma no tienen texto abajo
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart),
              activeIcon: Icon(CupertinoIcons.cart_fill),
              label: 'Carrito',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.location),
              activeIcon: Icon(CupertinoIcons.location_solid),
              label: 'Ubicación',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.ticket),
              activeIcon: Icon(CupertinoIcons.ticket_fill),
              label: 'Ticket',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.ellipsis),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}
