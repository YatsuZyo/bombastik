// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/domain/use_cases/commerce_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/presentation/screens/commerce/components/show_logout_confirmation.dart';
import 'package:flutter/services.dart';
import 'package:bombastik/presentation/widgets/gradient_card.dart';
import 'package:bombastik/presentation/widgets/gradient_app_bar.dart';
import 'package:bombastik/presentation/widgets/gradient_bottom_bar.dart';
import 'package:bombastik/presentation/providers/commerce_providers/auth/commerce_auth_provider.dart';

class CommerceHomeScreen extends ConsumerStatefulWidget {
  const CommerceHomeScreen({super.key});

  @override
  ConsumerState<CommerceHomeScreen> createState() => _CommerceHomeScreenState();
}

class _CommerceHomeScreenState extends ConsumerState<CommerceHomeScreen> {
  final _searchController = TextEditingController();
  final bool _isLoading = false;
  String? _companyName;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCommerceData();
  }

  Future<void> _loadCommerceData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('commerces')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        setState(() {
          _companyName = doc.data()?['companyName'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading commerce data: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${_companyName ?? 'Comercio'}!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.primary,
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
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Nuevo pedido recibido'),
                    subtitle: const Text('Hace 5 minutos'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navegar a la pantalla de pedidos
                      Navigator.pushNamed(context, '/commerce/orders');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Stock bajo en productos'),
                    subtitle: const Text('Hace 1 hora'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navegar a la pantalla de productos
                      Navigator.pushNamed(context, '/commerce/products');
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Estás seguro?'),
            content: const Text('¿Deseas salir de la aplicación?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir'),
              ),
            ],
          ),
    );
  }

  Future<bool?> showLogoutConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Estás seguro?'),
            content: const Text('¿Deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        Navigator.pushNamed(context, '/commerce/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showLogoutConfirmation(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'Dashboard',
          isDarkMode: isDark,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await showLogoutConfirmation(context);
                if (shouldLogout == true) {
                  ref
                      .read(commerceLoginControllerProvider.notifier)
                      .state = const AsyncValue.data(null);
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go('/commerce-login');
                  }
                }
              },
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
