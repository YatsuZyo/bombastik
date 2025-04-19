// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/presentation/providers/client-providers/dashboard/dashboard_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(dashboardIndexProvider);
    final router = ref.read(appRouterProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.surface.withOpacity(0.9),
                  theme.colorScheme.surface.withOpacity(0.7),
                ]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.9),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? theme.colorScheme.primary.withOpacity(0.2)
                : theme.colorScheme.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Spacer(flex: 1),
            _buildNavItem(
              0,
              Icons.chat_bubble_outline_rounded,
              'Chat',
              currentIndex,
              router,
              ref,
              theme,
              isDark,
            ),
            _buildVerticalDivider(theme, isDark),
            _buildNavItem(
              1,
              Icons.favorite_border_rounded,
              'Favoritos',
              currentIndex,
              router,
              ref,
              theme,
              isDark,
            ),
            const Spacer(flex: 1),
            _buildNavItem(
              2,
              Icons.home_rounded,
              'Inicio',
              currentIndex,
              router,
              ref,
              theme,
              isDark,
            ),
            const Spacer(flex: 1),
            _buildNavItem(
              3,
              Icons.shopping_cart_outlined,
              'Carrito',
              currentIndex,
              router,
              ref,
              theme,
              isDark,
            ),
            _buildVerticalDivider(theme, isDark),
            _buildNavItem(
              4,
              Icons.person_outline_rounded,
              'Perfil',
              currentIndex,
              router,
              ref,
              theme,
              isDark,
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(ThemeData theme, bool isDark) {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.onSurface.withOpacity(0.1),
            theme.colorScheme.onSurface.withOpacity(0.05),
            theme.colorScheme.onSurface.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int currentIndex,
    GoRouter router,
    WidgetRef ref,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = currentIndex == index;

    return SizedBox(
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _handleNavigation(index, router, ref),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(int index, GoRouter router, WidgetRef ref) {
    if (ref.read(dashboardIndexProvider) != index) {
      ref.read(dashboardIndexProvider.notifier).setIndex(index);
    }
  }
}
