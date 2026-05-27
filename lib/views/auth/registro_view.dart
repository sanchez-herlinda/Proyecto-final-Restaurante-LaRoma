import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../home/dashboard_view.dart';
import 'login_view.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🔴 FUNCIÓN DE TRANSICIÓN ANIMADA
  void _navegarALogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              // Movimiento inverso (izquierda a derecha)
              position: Tween<Offset>(
                begin: const Offset(-0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _intentarRegistro(BuildContext context) async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (nombre.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor llena todos los campos'),
            backgroundColor: AppColors.errorRed),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: AppColors.errorRed),
      );
      return;
    }

    await context.read<AuthProvider>().registro(nombre, email, password);

    if (!context.mounted) return;

    final authState = context.read<AuthProvider>().authState;
    if (authState.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().authState;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('La ROMA',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 42, color: AppColors.textDark)),
                const SizedBox(height: 10),
                const Divider(color: AppColors.dividerLine, thickness: 1),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: AppColors.primaryBrown, width: 2)),
                      ),
                      child: Text('Registro',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: _navegarALogin, // 🔴 Usar animación
                      child: Text('Iniciar Sesion',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildTextField(
                    hintText: 'Nombre de pila *',
                    controller: _nombreController,
                    obscureText: false),
                const SizedBox(height: 20),
                _buildTextField(
                    hintText: 'Email*',
                    controller: _emailController,
                    obscureText: false),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Contraseña*',
                  controller: _passwordController,
                  obscureText: _ocultarPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.primaryBrown,
                    ),
                    onPressed: () =>
                        setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Confirmar Contraseña*',
                  controller: _confirmPasswordController,
                  obscureText: _ocultarConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.primaryBrown,
                    ),
                    onPressed: () => setState(() =>
                        _ocultarConfirmPassword = !_ocultarConfirmPassword),
                  ),
                ),
                const SizedBox(height: 40),
                authState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBrown))
                    : ElevatedButton(
                        onPressed: () => _intentarRegistro(context),
                        child: const Text('Registrarse',
                            style: TextStyle(fontSize: 18)),
                      ),
                if (authState.isError) ...[
                  const SizedBox(height: 20),
                  Text(authState.errorMessage ?? 'Error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.errorRed))
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String hintText,
      required TextEditingController controller,
      required bool obscureText,
      Widget? suffixIcon}) {
    return Container(
      color: Colors.white.withValues(alpha: 0.5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textDark),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: AppColors.backgroundBeige.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
