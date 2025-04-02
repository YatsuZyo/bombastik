// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bombastik/domain/use_cases/client_login.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/infrastructure/services/auth_service.dart';

class ClientLoginScreen extends ConsumerStatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  ConsumerState<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends ConsumerState<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
        builder: (context) => const Center(child: CircularProgressIndicator()),
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
    final backgroundImage =
        isDarkMode
            ? 'assets/images/background_image_loginDarkMode.png'
            : 'assets/images/background_image_login.png';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  minHeight: 600, // Aumentamos la altura mínima
                ),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color.fromARGB(
                            255,
                            69,
                            68,
                            68,
                          ).withOpacity(0.95)
                          : Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¡Bienvenido a Bombastik!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Inicia sesión',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su email';
                          }
                          if (!value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // router.push('/forgot-password');
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : theme.colorScheme.secondary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  isDarkMode
                                      ? Colors.white
                                      : theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isLoading
                                ? CircularProgressIndicator(
                                  color: theme.colorScheme.onPrimary,
                                )
                                : Text(
                                  'Iniciar sesión',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDarkMode
                                            ? theme.colorScheme.onBackground
                                            : theme.colorScheme.onPrimary,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'o',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_icon.png',
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continuar con Google',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(appRouterProvider).push('/client-signup');
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "¿No posees una cuenta? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                TextSpan(
                                  text: '¡Regístrate aquí!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        isDarkMode
                                            ? Colors.white
                                            : theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
