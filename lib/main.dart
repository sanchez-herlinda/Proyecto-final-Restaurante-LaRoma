import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/carrito_provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/perfil_provider.dart';
import 'providers/sucursales_provider.dart';
import 'views/auth/login_view.dart'; // Importamos la vista del Login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LaRomaApp());
}

class LaRomaApp extends StatelessWidget {
  const LaRomaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Aquí inyectamos los Providers que hemos creado
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
        ChangeNotifierProvider(create: (_) => SucursalesProvider()),
      ],
      child: MaterialApp(
        title: 'La ROMA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // AQUÍ ESTABA EL TEXTO QUE VEÍAS. Ahora arranca en el Login.
        home: const LoginView(),
      ),
    );
  }
}
