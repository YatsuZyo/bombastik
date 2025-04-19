// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/use_cases/commerce_login.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommerceLoginScreen extends ConsumerStatefulWidget {
  const CommerceLoginScreen({super.key});

  @override
  ConsumerState<CommerceLoginScreen> createState() =>
      _CommerceLoginScreenState();
}

class _CommerceLoginScreenState extends ConsumerState<CommerceLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRifLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
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

    return WillPopScope(
      onWillPop: () async {
        ref.read(appRouterProvider).go('/mode-selector');
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isDark
                      ? [AppColors.darkGradientStart, AppColors.darkGradientEnd]
                      : [
                        AppColors.lightGradientStart,
                        AppColors.lightGradientEnd,
                      ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Botón de retroceso
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => ref.read(appRouterProvider).go('/mode-selector'),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? theme.colorScheme.surface.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo y título
                              Center(
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/In no time-amico.svg',
                                      height: 130,
                                      width: 130,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      '¡Bienvenido!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Inicia sesión en tu cuenta de comercio',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Selector de tipo de login
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.1),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Indicador animado
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.fastOutSlowIn,
                                      left: _isRifLogin ? 4 : null,
                                      right: _isRifLogin ? null : 4,
                                      top: 4,
                                      bottom: 4,
                                      width:
                                          (MediaQuery.of(context).size.width * 0.9 -
                                              64) /
                                          2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    // Botones
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildLoginTypeButton(
                                            isSelected: _isRifLogin,
                                            icon: Icons.badge_outlined,
                                            label: 'RIF',
                                            onTap:
                                                () => setState(() {
                                                  _isRifLogin = true;
                                                  _identifierController.clear();
                                                }),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildLoginTypeButton(
                                            isSelected: !_isRifLogin,
                                            icon: Icons.email_outlined,
                                            label: 'Email',
                                            onTap:
                                                () => setState(() {
                                                  _isRifLogin = false;
                                                  _identifierController.clear();
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Campos de entrada
                              CustomTextField(
                                controller: _identifierController,
                                label: _isRifLogin ? 'RIF' : 'Email',
                                hint:
                                    _isRifLogin
                                        ? 'Ingresa tu RIF'
                                        : 'Ingresa tu email',
                                keyboardType:
                                    _isRifLogin
                                        ? TextInputType.number
                                        : TextInputType.emailAddress,
                                prefixIcon:
                                    _isRifLogin
                                        ? Icons.badge_outlined
                                        : Icons.email_outlined,
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
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
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
                              // Botón de inicio de sesión
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child:
                                      _isLoading
                                          ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.onPrimary,
                                                  ),
                                            ),
                                          )
                                          : Text(
                                            'Iniciar Sesión',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Link para registro
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    ref
                                        .read(appRouterProvider)
                                        .push('/commerce-signin');
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      text: '¿No tienes una cuenta? ',
                                      style: GoogleFonts.poppins(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Regístrate aquí',
                                          style: GoogleFonts.poppins(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTypeButton({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
