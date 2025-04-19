// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final router = ref.read(appRouterProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkGradientStart, AppColors.darkGradientEnd]
                : [AppColors.lightGradientStart, AppColors.lightGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Logo y título
              Hero(
                tag: 'bombastikLogo',
                child: _buildLogoContainer(context),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 30),
              Text(
                'BOMBASTIK',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '¡Tu mejor opción de ahorro!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn().scale(delay: 400.ms),
              const Spacer(),
              // Botones
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStartButton(context, router)
                        .animate()
                        .fadeIn()
                        .scale(delay: 600.ms),
                    const SizedBox(height: 20),
                    _buildLoginPrompt(context, router)
                        .animate()
                        .fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoContainer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/images/BombastikBlancoSinFondoSized.png'
        : 'assets/images/BombastikLogoRecortadoRedi.png';

    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Image.asset(
        logoAsset,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, router) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) {
        setState(() => _isButtonPressed = false);
        router.push('/onboard');
      },
      onTapCancel: () => setState(() => _isButtonPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF9800),  // Naranja cálido
              const Color(0xFFF57C00),  // Naranja más profundo
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            if (!_isButtonPressed)
              BoxShadow(
                color: const Color(0xFFF57C00).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Center(
          child: Text(
            "¡Empecemos!",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, router) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => router.push('/client-login'),
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '¿Ya tienes una cuenta? ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                TextSpan(
                  text: 'Inicia sesión aquí',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
