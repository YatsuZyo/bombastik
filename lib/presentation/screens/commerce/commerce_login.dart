// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/use_cases/commerce_login.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:flutter/services.dart';

class CommerceLoginScreen extends ConsumerStatefulWidget {
  const CommerceLoginScreen({super.key});

  @override
  ConsumerState<CommerceLoginScreen> createState() =>
      _CommerceLoginScreenState();
}

class _CommerceLoginScreenState extends ConsumerState<CommerceLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRifLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(commerceLoginControllerProvider.notifier);
      await controller.loginCommerce(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text.trim(),
        isRif: _isRifLogin,
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundImage =
        isDark
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
              padding: const EdgeInsets.all(24),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? theme.colorScheme.surface.withOpacity(0.95)
                          : Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión en tu cuenta de comercio',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('RIF'),
                              value: true,
                              groupValue: _isRifLogin,
                              onChanged: (value) {
                                setState(() {
                                  _isRifLogin = value!;
                                  _identifierController.clear();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Email'),
                              value: false,
                              groupValue: _isRifLogin,
                              onChanged: (value) {
                                setState(() {
                                  _isRifLogin = value!;
                                  _identifierController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _identifierController,
                        label: _isRifLogin ? 'RIF' : 'Email',
                        hint:
                            _isRifLogin ? 'Ingresa tu RIF' : 'Ingresa tu email',
                        keyboardType:
                            _isRifLogin
                                ? TextInputType.number
                                : TextInputType.emailAddress,
                        prefixIcon: _isRifLogin ? Icons.badge : Icons.email,
                        prefixText: _isRifLogin ? 'J' : null,
                        inputFormatters:
                            _isRifLogin
                                ? [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                  LengthLimitingTextInputFormatter(9),
                                ]
                                : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _isRifLogin
                                ? 'Por favor ingresa tu RIF'
                                : 'Por favor ingresa tu email';
                          }
                          if (_isRifLogin) {
                            if (value.length != 9) {
                              return 'El RIF debe tener 9 números';
                            }
                          } else if (!value.contains('@')) {
                            return 'Por favor ingresa un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        hint: 'Ingresa tu contraseña',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Iniciar Sesión'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(appRouterProvider)
                                .push('/commerce-signin');
                          },
                          child: Text(
                            '¿No tienes una cuenta? Regístrate aquí',
                            style: TextStyle(color: theme.colorScheme.primary),
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
