// lib/presentation/screens/client/client_dashboard/profile_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/presentation/providers/client-providers/profile/profile_provider.dart'
    as main_provider;
import 'package:bombastik/presentation/screens/client/components/dialogs/show_edit_profile_dialog.dart'
    hide profileProvider;
import 'package:bombastik/presentation/screens/client/components/show_logout_confirmation.dart';
import 'package:bombastik/presentation/screens/client/profile/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:bombastik/domain/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(main_provider.profileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style:
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color:
                    theme.brightness == Brightness.dark
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
              ) ??
              TextStyle(),
          child: const Text('Mi Perfil'),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor:
            theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : theme.colorScheme.primary,
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(1.0),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color:
                    theme.brightness == Brightness.dark
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
              ),
              position: PopupMenuPosition.under,
              offset: const Offset(0, 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              elevation: 4,
              itemBuilder:
                  (context) => [
                    _buildPopupMenuItem(
                      icon: Icons.edit_rounded,
                      title: 'Editar perfil',
                      value: 'edit',
                      theme: theme,
                    ),

                    PopupMenuItem<String>(
                      height: 2,
                      enabled: false,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        indent: 12,
                        endIndent: 12,
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    _buildPopupMenuItem(
                      icon: Icons.settings_rounded,
                      title: 'Configuración',
                      value: 'settings',
                      theme: theme,
                    ),
                    _buildPopupMenuItem(
                      icon: Icons.help_center_rounded,
                      title: 'Ayuda',
                      value: 'help',
                      theme: theme,
                    ),
                    _buildPopupMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Sobre nosotros',
                      value: 'about',
                      theme: theme,
                    ),
                    PopupMenuItem<String>(
                      height: 2,
                      enabled: false,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        indent: 12,
                        endIndent: 12,
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    _buildPopupMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Cerrar sesión',
                      value: 'logout',
                      theme: theme,
                      isDestructive: true,
                    ),
                  ],
              onSelected: (value) async {
                await _handleMenuSelection(value, context, ref, profile, theme);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context, theme, profile, ref),
            const SizedBox(height: 24),
            _buildProfileDetails(theme, profile),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuSelection(
    String value,
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    ThemeData theme,
  ) async {
    switch (value) {
      case 'edit':
        await _showEditProfileWithTransition(context, ref, profile);
        break;
      case 'settings':
        _showComingSoonSnackbar(context, 'Configuración (próximamente)');
        break;
      case 'help':
        _showComingSoonSnackbar(context, 'Centro de ayuda (próximamente)');
        break;
      case 'about':
        _showComingSoonSnackbar(context, 'Sobre nosotros (próximamente)');
        break;
      case 'logout':
        await _handleLogout(context, ref, theme);
        break;
    }
  }

  Future<void> _showEditProfileWithTransition(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder:
            (_, __, ___) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: ScaleTransition(
                scale: CurvedAnimation(parent: __, curve: Curves.easeOutBack),
                child: showEditProfileDialog(
                  context: context,
                  ref: ref,
                  currentProfile: profile,
                  isStandalone: true,
                ),
              ),
            ),
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) async {
    final shouldLogOut = await showLogoutConfirmation(
      context: context,
      onLogout: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sesión cerrada', style: theme.textTheme.bodyLarge),
            backgroundColor: theme.colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(appRouterProvider).push('/client-login');
      },
    );
    if (shouldLogOut) {}
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    UserProfile profile,
    WidgetRef ref,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: ProfileAvatar(
              imageUrl:
                  '${profile.photoUrl}?t=${DateTime.now().millisecondsSinceEpoch}',
              radius: 50,
              onImageSelected: (imageFile) async {
                final notifier = ref.read(
                  main_provider.profileProvider.notifier,
                );
                final newUrl = await notifier.uploadImageWithConfirmation(
                  context: context,
                  imageFile: imageFile,
                );
                if (newUrl != null) {
                  await ref
                      .read(main_provider.profileProvider.notifier)
                      .updateProfileData({'photoUrl': newUrl});
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Foto de perfil actualizada')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              profile.name ?? 'Nombre no especificado',
              key: ValueKey<String>(profile.name ?? ''),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              profile.email,
              key: ValueKey<String>(profile.email),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(ThemeData theme, UserProfile profile) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.colorScheme.surface,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDetailItem(
                theme: theme,
                icon: Icons.phone,
                title: 'Teléfono',
                value: profile.phone,
              ),
              Divider(
                height: 24,
                color: theme.colorScheme.onSurface.withOpacity(0.2),
              ),
              _buildDetailItem(
                theme: theme,
                icon: Icons.location_on,
                title: 'Dirección',
                value: profile.address,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String? value,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    value ?? 'No especificado',
                    key: ValueKey<String>(value ?? 'null'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive
            ? Colors.red
            : theme.colorScheme.onSurface.withOpacity(0.8);

    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
