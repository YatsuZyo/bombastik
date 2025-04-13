import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/domain/use_cases/commerce_login.dart';
import 'package:bombastik/presentation/widgets/gradient_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CommerceProfileScreen extends ConsumerStatefulWidget {
  const CommerceProfileScreen({super.key});

  @override
  ConsumerState<CommerceProfileScreen> createState() =>
      _CommerceProfileScreenState();
}

class _CommerceProfileScreenState extends ConsumerState<CommerceProfileScreen> {
  String? _companyName;
  String? _email;
  String? _phone;
  String? _address;
  String? _category;
  bool _isLoading = true;

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

      if (doc.exists && mounted) {
        setState(() {
          _companyName = doc.data()?['companyName'] as String?;
          _email = doc.data()?['email'] as String?;
          _phone = doc.data()?['phone'] as String?;
          _address = doc.data()?['address'] as String?;
          _category = doc.data()?['category'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading commerce data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileSection(ThemeData theme, bool isDark) {
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
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.store_rounded, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _companyName ?? 'Comercio',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_category != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _category!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String? value,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'No especificado',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (color ?? theme.colorScheme.primary).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color ?? theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Mi Perfil',
        isDarkMode: isDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileSection(theme, isDark),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Comercio',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoTile(
                            icon: Icons.email_outlined,
                            title: 'Correo Electrónico',
                            value: _email,
                            theme: theme,
                          ),
                          _buildInfoTile(
                            icon: Icons.phone_outlined,
                            title: 'Teléfono',
                            value: _phone,
                            theme: theme,
                          ),
                          _buildInfoTile(
                            icon: Icons.location_on_outlined,
                            title: 'Dirección',
                            value: _address,
                            theme: theme,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Acciones',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Editar Perfil',
                            onTap: () {
                              // TODO: Implementar edición de perfil
                            },
                            theme: theme,
                          ),
                          _buildActionButton(
                            icon: Icons.settings_outlined,
                            label: 'Configuración',
                            onTap: () {
                              // TODO: Implementar configuración
                            },
                            theme: theme,
                          ),
                          _buildActionButton(
                            icon: Icons.logout,
                            label: 'Cerrar Sesión',
                            onTap: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('¿Estás seguro?'),
                                      content: const Text(
                                        '¿Deseas cerrar sesión?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Cerrar Sesión'),
                                        ),
                                      ],
                                    ),
                              );

                              if (shouldLogout == true && mounted) {
                                ref
                                    .read(
                                      commerceLoginControllerProvider.notifier,
                                    )
                                    .state = const AsyncValue.data(null);
                                await FirebaseAuth.instance.signOut();
                                if (context.mounted) {
                                  context.go('/commerce-login');
                                }
                              }
                            },
                            theme: theme,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
