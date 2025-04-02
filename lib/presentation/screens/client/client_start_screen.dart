// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    return Scaffold(
      backgroundColor:
          theme.colorScheme.background, // Cambiado de surface a background

      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'bombastikLogo',
                      child: _buildLogoContainer(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        'BOMBASTIK',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '¡Tu mejor opción de ahorro!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildStartButton(context, router),
                  const SizedBox(height: 16),
                  _buildLoginPrompt(context, router),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoContainer(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final logoAsset =
        isDarkMode
            ? 'assets/images/BombastikBlancoSinFondoSized.png'
            : 'assets/images/BombastikLogoRecortadoRedi.png';

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          fit: BoxFit.contain, // Cambiado de cover a contain para mejor ajuste
          image: AssetImage(logoAsset),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, router) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) {
        setState(() => _isButtonPressed = false);
        router.push('/onboard');
      },
      onTapCancel: () => setState(() => _isButtonPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isButtonPressed ? 300 : 250,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!_isButtonPressed)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            "¡Empecemos!",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  isDarkMode
                      ? theme.colorScheme.onBackground
                      : theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, router) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => router.push('/client-login'),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '¿Ya tienes una cuenta? ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            TextSpan(
              text: 'Inicia sesión aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
