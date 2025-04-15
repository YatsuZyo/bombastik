import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/domain/models/commerce_profile.dart';
import 'package:bombastik/domain/providers/commerce_profile_provider.dart';
import 'package:bombastik/domain/use_cases/commerce_login.dart';
import 'package:bombastik/infrastructure/services/imgbb_service.dart';
import 'package:bombastik/presentation/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CommerceProfileScreen extends ConsumerWidget {
  const CommerceProfileScreen({super.key});

  Widget _buildProfileSection(
    ThemeData theme,
    bool isDark,
    CommerceProfile profile,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _handleImageChange(context, ref),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage:
                          profile.photoUrl != null
                              ? NetworkImage(profile.photoUrl ?? '')
                              : null,
                      child:
                          profile.photoUrl == null
                              ? Icon(
                                Icons.store_rounded,
                                size: 50,
                                color: Colors.white.withOpacity(0.95),
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile.companyName ?? 'Comercio',
            style: GoogleFonts.poppins(
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (profile.category != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                profile.category,
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleImageChange(BuildContext context, WidgetRef ref) async {
    final imgBBService = ImgBBService(
      apiKey: '9106f089320713928b1662d1c6fdafab',
    );

    try {
      final imageFile = await imgBBService.pickImage(context);
      if (imageFile == null || !context.mounted) return;

      final shouldUpload = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder:
            (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¿Usar esta imagen?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        imageFile,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Esta imagen se usará como logo de tu comercio',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(
                          'Usar Imagen',
                          style: GoogleFonts.poppins(
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
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      if (shouldUpload != true || !context.mounted) return;

      BuildContext? dialogContext;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Subiendo imagen...', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ),
          );
        },
      );

      String? imageUrl;
      try {
        imageUrl = await imgBBService.uploadImage(imageFile);
      } catch (e) {
        if (dialogContext != null && context.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al subir la imagen: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (imageUrl == null) {
        if (dialogContext != null && context.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        return;
      }

      try {
        final currentProfile =
            ref.read(commerceProfileControllerProvider).value;
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(photoUrl: imageUrl);
          await ref
              .read(commerceProfileControllerProvider.notifier)
              .updateProfile(updatedProfile);

          if (dialogContext != null && context.mounted) {
            Navigator.of(dialogContext!).pop();
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logo actualizado correctamente',
                style: GoogleFonts.poppins(),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (dialogContext != null && context.mounted) {
          Navigator.of(dialogContext!).pop();
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar el perfil: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al seleccionar la imagen: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'No especificado',
                  style: GoogleFonts.poppins(
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
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
    final buttonColor = color ?? theme.colorScheme.primary;

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
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: buttonColor.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: buttonColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: buttonColor.withOpacity(0.5),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsync = ref.watch(commerceProfileControllerProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Mi Perfil',
        isDarkMode: isDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/commerce-home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    ref
                        .read(commerceProfileControllerProvider.notifier)
                        .refreshProfile(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el perfil',
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        () => ref.refresh(commerceProfileControllerProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Reintentar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontró el perfil del comercio',
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, asegúrate de que has iniciado sesión correctamente',
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        () => ref.refresh(commerceProfileControllerProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Reintentar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileSection(theme, isDark, profile, context, ref),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Comercio',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Correo Electrónico',
                        value: profile.email,
                        theme: theme,
                      ),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Teléfono',
                        value: profile.phone,
                        theme: theme,
                      ),
                      _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        title: 'Dirección',
                        value: profile.address,
                        theme: theme,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Acciones',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
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
                            barrierDismissible: false,
                            builder:
                                (
                                  dialogContext,
                                ) => TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 250),
                                  tween: Tween(begin: 0.8, end: 1.0),
                                  curve: Curves.easeOutCubic,
                                  builder:
                                      (context, scale, child) =>
                                          Transform.scale(
                                            scale: scale,
                                            child: child,
                                          ),
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
                                                    AppColors
                                                        .statsGradientDarkStart,
                                                    AppColors
                                                        .statsGradientDarkEnd,
                                                  ]
                                                  : [
                                                    AppColors
                                                        .statsGradientStart,
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
                                      '¿Cerrar Sesión?',
                                      style: GoogleFonts.poppins(
                                        textStyle: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      'Al cerrar sesión, tendrás que volver a iniciar sesión para acceder a tu cuenta.',
                                      style: GoogleFonts.poppins(
                                        textStyle: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actionsPadding: const EdgeInsets.fromLTRB(
                                      24,
                                      0,
                                      24,
                                      24,
                                    ),
                                    actions: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            foregroundColor:
                                                theme.colorScheme.onError,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.pop(
                                                dialogContext,
                                                true,
                                              ),
                                          child: Text(
                                            'Cerrar Sesión',
                                            style: GoogleFonts.poppins(
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
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.pop(
                                                dialogContext,
                                                false,
                                              ),
                                          child: Text(
                                            'Cancelar',
                                            style: GoogleFonts.poppins(
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

                          if (shouldLogout == true && context.mounted) {
                            await ref
                                .read(commerceLoginControllerProvider.notifier)
                                .logout();
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
          );
        },
      ),
    );
  }
}
