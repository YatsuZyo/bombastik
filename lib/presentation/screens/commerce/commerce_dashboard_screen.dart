import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/presentation/widgets/gradient_bottom_bar.dart';
import 'package:bombastik/domain/providers/commerce_profile_provider.dart';
import 'package:flutter/services.dart';

class CommerceDashboard extends ConsumerStatefulWidget {
  final Widget child;

  const CommerceDashboard({super.key, required this.child});

  @override
  ConsumerState<CommerceDashboard> createState() => _CommerceDashboardState();
}

class _CommerceDashboardState extends ConsumerState<CommerceDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Actualizar el índice basado en la ruta actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPath =
          GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      if (currentPath.contains('profile')) {
        setState(() => _selectedIndex = 1);
      } else {
        setState(() => _selectedIndex = 0);
      }
    });
  }

  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.easeOutCubic,
            builder:
                (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
            child: AlertDialog(
              backgroundColor: theme.cardColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              icon: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isDark
                            ? [
                              AppColors.statsGradientDarkStart,
                              AppColors.statsGradientDarkEnd,
                            ]
                            : [
                              AppColors.statsGradientStart,
                              AppColors.statsGradientEnd,
                            ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              title: Text(
                '¿Salir de la Aplicación?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Si sales de la aplicación, tendrás que volver a abrirla para acceder a tu cuenta. ¿Estás seguro?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                      if (mounted) {
                        SystemNavigator.pop();
                      }
                    },
                    child: const Text(
                      'Salir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    return false;
  }

  void _onItemTapped(int index) async {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/commerce-home');
        break;
      case 1:
        // Asegurarnos de que el perfil esté cargado antes de navegar
        final profileAsync = ref.read(commerceProfileControllerProvider);
        if (profileAsync.hasValue && profileAsync.value != null) {
          context.go('/commerce-profile');
        } else {
          // Intentar cargar el perfil
          await ref
              .read(commerceProfileControllerProvider.notifier)
              .refreshProfile();
          if (mounted) {
            final updatedProfile = ref.read(commerceProfileControllerProvider);
            if (updatedProfile.hasValue && updatedProfile.value != null) {
              context.go('/commerce-profile');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Error al cargar el perfil. Intente nuevamente.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() => _selectedIndex = 0);
            }
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: GradientBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          isDarkMode: isDark,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
