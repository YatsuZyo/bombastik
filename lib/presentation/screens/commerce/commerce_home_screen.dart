// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/domain/providers/commerce_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/presentation/widgets/gradient_card.dart';
import 'package:bombastik/presentation/widgets/gradient_app_bar.dart';
import 'package:flutter/services.dart';

class CommerceHomeScreen extends ConsumerStatefulWidget {
  const CommerceHomeScreen({super.key});

  @override
  ConsumerState<CommerceHomeScreen> createState() => _CommerceHomeScreenState();
}

class _CommerceHomeScreenState extends ConsumerState<CommerceHomeScreen> {
  final _searchController = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar los datos solo si no están disponibles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final profileState = ref.read(commerceProfileControllerProvider);
      if (profileState.value == null && !profileState.isLoading) {
        ref.read(commerceProfileControllerProvider.notifier).refreshProfile();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final profileAsync = ref.watch(commerceProfileControllerProvider);

    return Container(
      padding: const EdgeInsets.all(24),
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
                  : [AppColors.statsGradientStart, AppColors.statsGradientEnd],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileAsync.maybeWhen(
                        data:
                            (profile) =>
                                profile?.companyName != null
                                    ? '¡Hola, ${profile!.companyName}!'
                                    : '¡Hola, Comercio!',
                        orElse: () => '¡Hola, Comercio!',
                      ),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¡Bienvenido a tu dashboard!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: _showNotificationsDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return GradientCard(
      isDarkMode: isDark,
      customGradient:
          isDark
              ? [
                AppColors.statsGradientDarkStart,
                AppColors.statsGradientDarkEnd,
              ]
              : [AppColors.statsGradientStart, AppColors.statsGradientEnd],
      builder:
          (iconColor, titleColor, textColor) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final router = ref.read(appRouterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Acciones Rápidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Gestionar Productos',
              onTap: () => router.push('/commerce-products'),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Pedidos',
              onTap: () => router.push('/commerce-orders'),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.analytics_outlined,
              title: 'Estadísticas',
              onTap:
                  () => _showComingSoonSnackbar(
                    context,
                    'Estadísticas (próximamente)',
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determinar el gradiente según el título
    List<Color> gradient;
    if (title.contains('Productos')) {
      gradient = [
        AppColors.productsGradientStart,
        AppColors.productsGradientEnd,
      ];
    } else if (title.contains('Pedidos')) {
      gradient = [AppColors.ordersGradientStart, AppColors.ordersGradientEnd];
    } else {
      gradient = [
        AppColors.analyticsGradientStart,
        AppColors.analyticsGradientEnd,
      ];
    }

    // Si es modo oscuro, hacer el gradiente más suave
    if (isDark) {
      gradient = gradient.map((color) => color.withOpacity(0.7)).toList();
    }

    return GradientCard(
      isDarkMode: isDark,
      customGradient: gradient,
      onTap: onTap,
      builder:
          (iconColor, titleColor, textColor) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationsDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(dialogContext).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Notificaciones'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Theme.of(dialogContext).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Nuevo pedido recibido'),
                    subtitle: const Text('Hace 5 minutos'),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      context.push('/commerce-orders');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Theme.of(dialogContext).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Stock bajo en productos'),
                    subtitle: const Text('Hace 1 hora'),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      context.push('/commerce-products');
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    if (!mounted) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldLogout = await showDialog<bool>(
      context: context,
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
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              title: Text(
                '¿Cerrar Sesión?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                '¿Estás seguro que deseas cerrar tu sesión? Tendrás que iniciar sesión nuevamente para acceder a tu cuenta.',
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
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text(
                      'Cerrar Sesión',
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

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.go('/commerce-login');
    }
  }

  Future<bool> _onWillPop() async {
    if (!mounted) return false;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
                  Icons.exit_to_app_rounded,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        appBar: GradientAppBar(
          title: 'Dashboard',
          isDarkMode: isDark,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(theme, isDark)),
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                        delegate: SliverChildListDelegate([
                          _buildStatsCard(
                            theme,
                            'Pedidos Hoy',
                            '12',
                            Icons.shopping_bag_outlined,
                          ),
                          _buildStatsCard(
                            theme,
                            'Productos',
                            '45',
                            Icons.inventory_2_outlined,
                          ),
                          _buildStatsCard(
                            theme,
                            'Ventas Hoy',
                            '\$1,234',
                            Icons.attach_money_outlined,
                          ),
                          _buildStatsCard(
                            theme,
                            'Clientes',
                            '89',
                            Icons.people_outline,
                          ),
                        ]),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildQuickActions(theme)),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
      ),
    );
  }
}
