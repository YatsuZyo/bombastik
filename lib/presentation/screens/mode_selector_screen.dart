// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModeSelectorScreen extends ConsumerWidget {
  const ModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(appRouterProvider);
    final theme = Theme.of(context);
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
              const SizedBox(height: 20),
              // Logo animado
              Image.asset(
                isDark
                    ? 'assets/images/BombastikLogoDarkMode.png'
                    : 'assets/images/BombastikBlancoSinFondoSized.png',
                height: 130,
                fit: BoxFit.contain,
              ).animate().fadeIn().scale(),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(isDark ? 0.9 : 0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Cómo deseas continuar?',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 8),
                      Text(
                        'Puedes cambiar de un modo a otro siempre que quieras.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            ModeCard(
                              imagePath: 'assets/images/icon_cliente_resized.png',
                              title: 'Seguir como cliente',
                              description: '¡Navega a través de la app y encuentra las mejores ofertas!',
                              onTap: () => router.push('/client-start'),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.8),
                                  theme.colorScheme.primary,
                                ],
                              ),
                            ).animate().fadeIn().scale().moveY(begin: 30, delay: 200.ms),
                            const SizedBox(height: 20),
                            ModeCard(
                              imagePath: 'assets/images/icon_comercio.png',
                              title: 'Seguir como comercio',
                              description: 'Administra tu comercio y visualiza tu dashboard de órdenes.',
                              onTap: () => router.push('/commerce-login'),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.secondary.withOpacity(0.8),
                                  theme.colorScheme.secondary,
                                ],
                              ),
                            ).animate().fadeIn().scale().moveY(begin: 30, delay: 400.ms),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Gradient gradient;

  const ModeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
