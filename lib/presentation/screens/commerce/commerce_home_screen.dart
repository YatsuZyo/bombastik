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
import 'package:google_fonts/google_fonts.dart';

class CommerceHomeScreen extends ConsumerStatefulWidget {
  const CommerceHomeScreen({super.key});

  @override
  ConsumerState<CommerceHomeScreen> createState() => _CommerceHomeScreenState();
}

class _CommerceHomeScreenState extends ConsumerState<CommerceHomeScreen> {
  final _searchController = TextEditingController();
  final bool _isLoading = false;
  bool _hasUnreadNotifications = true; // Estado temporal para pruebas

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
              Stack(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              isDark
                                  ? [
                                    AppColors.statsGradientDarkStart
                                        .withOpacity(0.8),
                                    AppColors.statsGradientDarkEnd.withOpacity(
                                      0.9,
                                    ),
                                  ]
                                  : [
                                    AppColors.statsGradientStart.withOpacity(
                                      0.8,
                                    ),
                                    AppColors.statsGradientEnd.withOpacity(0.9),
                                  ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasUnreadNotifications = false;
                      });
                      _showNotificationsDialog();
                    },
                  ),
                  if (_hasUnreadNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.statsGradientDarkStart
                                    : AppColors.statsGradientStart,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        theme.colorScheme.surface.withOpacity(0.3),
                        theme.colorScheme.surface.withOpacity(0.1),
                      ]
                      : [
                        const Color(0xFFE0F2F1).withOpacity(0.9),
                        const Color(0xFFB2DFDB).withOpacity(0.6),
                        const Color(0xFF80CBC4).withOpacity(0.3),
                      ],
              stops: isDark ? [0.0, 1.0] : [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black12
                        : const Color(0xFF80CBC4).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.bolt_outlined,
                  size: 60,
                  color:
                      isDark
                          ? theme.colorScheme.primary
                          : const Color(0xFF00897B),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones Rápidas',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? theme.colorScheme.onBackground
                              : const Color(0xFF00897B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Gestiona tu negocio de manera eficiente',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color:
                            isDark
                                ? theme.colorScheme.onBackground.withOpacity(
                                  0.7,
                                )
                                : const Color(0xFF00897B).withOpacity(0.7),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildQuickActionCard(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'Gestionar\nProductos',
                onTap: () => router.push('/commerce-products'),
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Ver\nPedidos',
                onTap: () => router.push('/commerce-orders'),
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.local_offer_outlined,
                title: 'Gestionar\nPromociones',
                onTap: () => router.push('/commerce-promotions'),
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.analytics_outlined,
                title: 'Ver\nEstadísticas',
                onTap: () => router.push('/commerce-stats'),
              ),
            ],
          ),
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
    Color iconBackgroundColor;
    Color iconColor;

    if (title.contains('Productos')) {
      gradient =
          isDark
              ? [
                AppColors.productsGradientStart.withOpacity(0.8),
                AppColors.productsGradientEnd.withOpacity(0.9),
              ]
              : [
                AppColors.productsGradientStart,
                AppColors.productsGradientEnd,
              ];
      iconBackgroundColor = AppColors.productsGradientStart.withOpacity(0.2);
      iconColor = AppColors.productsGradientEnd;
    } else if (title.contains('Pedidos')) {
      gradient =
          isDark
              ? [
                AppColors.ordersGradientStart.withOpacity(0.8),
                AppColors.ordersGradientEnd.withOpacity(0.9),
              ]
              : [AppColors.ordersGradientStart, AppColors.ordersGradientEnd];
      iconBackgroundColor = AppColors.ordersGradientStart.withOpacity(0.2);
      iconColor = AppColors.ordersGradientEnd;
    } else if (title.contains('Promociones')) {
      gradient =
          isDark
              ? [
                const Color(0xFF9C27B0).withOpacity(0.8),
                const Color(0xFFE91E63).withOpacity(0.9),
              ]
              : [const Color(0xFF9C27B0), const Color(0xFFE91E63)];
      iconBackgroundColor = const Color(0xFF9C27B0).withOpacity(0.2);
      iconColor = const Color(0xFFE91E63);
    } else {
      gradient =
          isDark
              ? [
                AppColors.analyticsGradientStart.withOpacity(0.8),
                AppColors.analyticsGradientEnd.withOpacity(0.9),
              ]
              : [
                AppColors.analyticsGradientStart,
                AppColors.analyticsGradientEnd,
              ];
      iconBackgroundColor = AppColors.analyticsGradientStart.withOpacity(0.2);
      iconColor = AppColors.analyticsGradientEnd;
    }

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: gradient[0].withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
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
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
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
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Notificaciones',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNotificationItem(
                      context: dialogContext,
                      icon: Icons.shopping_bag_outlined,
                      title: 'Nuevo pedido recibido',
                      subtitle: 'Hace 5 minutos',
                      onTap: () {
                        Navigator.pop(dialogContext);
                        if (!mounted) return;
                        context.push('/commerce-orders');
                      },
                    ),
                    const Divider(height: 24),
                    _buildNotificationItem(
                      context: dialogContext,
                      icon: Icons.inventory_2_outlined,
                      title: 'Stock bajo en productos',
                      subtitle: 'Hace 1 hora',
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
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cerrar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
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
