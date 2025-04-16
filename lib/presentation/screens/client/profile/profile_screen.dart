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
import 'package:google_fonts/google_fonts.dart';

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [
                  const Color(0xFF568028),  // Verde oscuro principal
                  const Color(0xFF2A7654),  // Verde oscuro secundario
                  const Color(0xFF1E3A4C),  // Azul oscuro para profundidad
                ]
              : [
                  const Color(0xFF86C144),  // Verde principal
                  const Color(0xFF42B883),  // Verde secundario
                  const Color(0xFF6EA037),  // Verde más oscuro para profundidad
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? const Color(0xFF568028).withOpacity(0.5)
                : const Color(0xFF86C144).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ]
                        : [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.2),
                          ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const ThemeSwitch(),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ]
                          : [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.2),
                            ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                ),
                onPressed: () => _showComingSoonSnackbar(context, 'Configuración (próximamente)'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
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
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFFFF9800),
                              const Color(0xFFF57C00),
                            ]
                          : [
                              const Color(0xFFFFC107),
                              const Color(0xFFFF9800),
                            ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.name ?? 'Usuario',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF86C144).withOpacity(0.2),
                        const Color(0xFF42B883).withOpacity(0.1),
                      ]
                    : [
                        const Color(0xFF86C144).withOpacity(0.3),
                        const Color(0xFF42B883).withOpacity(0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF86C144).withOpacity(0.3)
                    : const Color(0xFF42B883).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Cliente',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showEditProfileWithTransition(context, ref, profile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF86C144),
                          const Color(0xFF42B883),
                        ]
                      : [
                          const Color(0xFF86C144),
                          const Color(0xFF42B883),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF86C144).withOpacity(0.4)
                        : const Color(0xFF42B883).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Editar Perfil',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
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
