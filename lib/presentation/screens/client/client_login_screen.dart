// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bombastik/domain/use_cases/client_login.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/infrastructure/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientLoginScreen extends ConsumerStatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  ConsumerState<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends ConsumerState<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(clientLoginControllerProvider.notifier);
    final router = ref.read(appRouterProvider);

    try {
      await controller.loginCliente(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(_getErrorMessage(e));
    } catch (e) {
      _showErrorSnackbar('Error inesperado');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Cliente no registrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'invalid-role':
        return 'Esta cuenta no es de cliente';
      default:
        return e.message ?? 'Error al iniciar sesión';
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A4C).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Iniciando sesión...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      final authService = AuthService();
      final user = await authService.signInWithGoogle();
      final router = ref.read(appRouterProvider);

      if (user != null) {
        final role = await authService.getUserRole(user.uid);
        if (role == 'cliente') {
          Navigator.of(context).pop();
          router.pushReplacement('/home');
        } else {
          await authService.signOut();
          Navigator.of(context).pop(); // Cerrar el diálogo de carga
          _showErrorSnackbar('Esta cuenta no es de cliente');
        }
      } else {
        Navigator.of(
          context,
        ).pop(); // Cerrar el diálogo de carga si user es null
      }
    } catch (e) {
      Navigator.of(
        context,
      ).pop(); // Cerrar el diálogo de carga en caso de error
      _showErrorSnackbar('Error al iniciar con Google');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(clientLoginControllerProvider).isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.lightGradientStart, AppColors.lightGradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Botón de retroceso
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: 20),

                  // Imagen decorativa
                  SvgPicture.asset(
                    'assets/images/loginamico.svg',
                    height: 220,
                    width: 220,
                    fit: BoxFit.contain,
                  ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),

                  const SizedBox(height: 30),

                  // Formulario
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A4C).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título de Iniciar sesión
                            Text(
                              'Iniciar sesión',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn().slideX(delay: 200.ms),

                            const SizedBox(height: 24),

                            // Email
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A4C),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Correo Electrónico',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 20,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: Colors.white70,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su correo';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                            ).animate().fadeIn().slideX(delay: 300.ms),

                            const SizedBox(height: 16),

                            // Contraseña
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A4C),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Contraseña',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 20,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white70,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su contraseña';
                                  }
                                  return null;
                                },
                              ),
                            ).animate().fadeIn().slideX(delay: 400.ms),

                            const SizedBox(height: 30),

                            // Botón de inicio de sesión
                            GestureDetector(
                              onTapDown:
                                  (_) =>
                                      setState(() => _isButtonPressed = true),
                              onTapUp: (_) {
                                setState(() => _isButtonPressed = false);
                                _submit();
                              },
                              onTapCancel:
                                  () =>
                                      setState(() => _isButtonPressed = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF9800),
                                      const Color(0xFFF57C00),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    if (!_isButtonPressed)
                                      BoxShadow(
                                        color: const Color(
                                          0xFFF57C00,
                                        ).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                  ],
                                ),
                                child: Center(
                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Iniciar Sesión',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.login_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ).animate().fadeIn().scale(delay: 500.ms),

                            const SizedBox(height: 20),

                            // Separador
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'O continúa con',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 600.ms),

                            const SizedBox(height: 20),

                            // Botón de Google
                            GestureDetector(
                              onTap: _signInWithGoogle,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_icon.png',
                                      height: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continuar con Google',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().scale(delay: 700.ms),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/client-signin'),
                          child: Text(
                            'Regístrate',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
