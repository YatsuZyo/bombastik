// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/presentation/screens/commerce/components/show_logout_confirmation.dart';

class CommerceHomeScreen extends ConsumerStatefulWidget {
  const CommerceHomeScreen({super.key});

  @override
  ConsumerState<CommerceHomeScreen> createState() => _CommerceHomeScreenState();
}

class _CommerceHomeScreenState extends ConsumerState<CommerceHomeScreen> {
  final _searchController = TextEditingController();
  final bool _isLoading = false;
  String? _companyName;

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
        color: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
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
                      color:
                          isDark
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¡Bienvenido a tu dashboard!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          isDark
                              ? theme.colorScheme.onSurface.withOpacity(0.7)
                              : theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color:
                      isDark
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onPrimary,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
              icon: Icons.add_circle_outline,
              title: 'Nuevo Producto',
              onTap: () => router.push('/commerce-products'),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Gestionar Productos',
              onTap: () => router.push('/commerce-products'),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.shopping_cart_outlined,
              title: 'Pedidos',
              onTap:
                  () => _showComingSoonSnackbar(
                    context,
                    'Pedidos (próximamente)',
                  ),
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color:
                    isDark
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
    // TODO(jorge): Implementar notificaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificaciones próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> showLogoutConfirmationDialog(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showLogoutConfirmationDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await showLogoutConfirmationDialog(
                  context,
                );
                if (shouldLogout == true && context.mounted) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go('/');
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
      ),
    );
  }
}
