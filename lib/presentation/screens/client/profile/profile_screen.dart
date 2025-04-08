// lib/presentation/screens/client/profile/profile_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/presentation/providers/client-providers/profile/profile_provider.dart';
import 'package:bombastik/presentation/screens/client/components/dialogs/show_edit_profile_dialog.dart';
import 'package:bombastik/presentation/screens/client/components/show_logout_confirmation.dart';
import 'package:bombastik/presentation/screens/client/components/theme_switch.dart';
import 'package:bombastik/presentation/screens/client/profile/profile_avatar.dart';
import 'package:bombastik/presentation/screens/client/profile/profile_option_card.dart';
import 'package:flutter/material.dart';
import 'package:bombastik/domain/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildHeader(UserProfile profile, ThemeData theme, bool isDark) {
    final headerTextColor = isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 48,
                child: Center(child: ThemeSwitch()),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: isDark ? theme.colorScheme.primary : headerTextColor,
                ),
                onPressed: () => _showComingSoonSnackbar(context, 'Configuración (próximamente)'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ProfileAvatar(
            imageUrl: profile.photoUrl,
            radius: 50,
            onImageSelected: (imageFile) async {
              final notifier = ref.read(profileProvider.notifier);
              await notifier.uploadImageWithConfirmation(
                context: context,
                imageFile: imageFile,
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            profile.name ?? 'Usuario',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: headerTextColor,
            ),
          ),
          Text(
            'Cliente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: headerTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showEditProfileWithTransition(context, ref, profile),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? theme.colorScheme.primary : headerTextColor,
              foregroundColor: isDark ? headerTextColor : theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(ThemeData theme) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      delegate: SliverChildListDelegate([
        ProfileOptionCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Mis Pedidos',
          onTap: () => _showComingSoonSnackbar(context, 'Mis Pedidos (próximamente)'),
        ),
        ProfileOptionCard(
          icon: Icons.favorite_border_rounded,
          title: 'Favoritos',
          onTap: () => ref.read(appRouterProvider).push('/favorites'),
        ),
        ProfileOptionCard(
          icon: Icons.local_offer_outlined,
          title: 'Ofertas',
          onTap: () => _showComingSoonSnackbar(context, 'Ofertas (próximamente)'),
        ),
        ProfileOptionCard(
          icon: Icons.wallet_outlined,
          title: 'Métodos de Pago',
          onTap: () => _showComingSoonSnackbar(context, 'Métodos de Pago (próximamente)'),
        ),
        ProfileOptionCard(
          icon: Icons.location_on_outlined,
          title: 'Direcciones',
          onTap: () => _showComingSoonSnackbar(context, 'Direcciones (próximamente)'),
        ),
        ProfileOptionCard(
          icon: Icons.logout_rounded,
          title: 'Cerrar Sesión',
          iconColor: Colors.red,
          onTap: () => _handleLogout(context, ref, theme),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final profile = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(profile, theme, isDark),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: _buildOptionsGrid(theme),
            ),
          ],
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

  Future<void> _showEditProfileWithTransition(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    if (!mounted) return;
    
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
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

  Future<void> _handleLogout(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) async {
    if (!mounted) return;
    
    final shouldLogOut = await showLogoutConfirmation(
      context: context,
      onLogout: () {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sesión cerrada',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
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
}
