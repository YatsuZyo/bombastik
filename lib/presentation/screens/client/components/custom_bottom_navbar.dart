// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/presentation/providers/client-providers/dashboard/dashboard_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(dashboardIndexProvider);
    final router = ref.read(appRouterProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.22), // Sombra verde
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              Icons.chat_bubble_outline,
              currentIndex,
              router,
              ref,
              theme,
            ),
            _buildVerticalDivider(theme),
            _buildNavItem(
              1,
              Icons.favorite_border,
              currentIndex,
              router,
              ref,
              theme,
            ),
            const Spacer(flex: 1),
            _buildNavItem(2, Icons.home, currentIndex, router, ref, theme),
            const Spacer(flex: 1),
            _buildNavItem(
              3,
              Icons.shopping_cart_outlined,
              currentIndex,
              router,
              ref,
              theme,
            ),
            _buildVerticalDivider(theme),
            _buildNavItem(
              4,
              Icons.person_outline,
              currentIndex,
              router,
              ref,
              theme,
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      height: 30,
      width: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: theme.colorScheme.onSurface.withOpacity(0.1),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    int currentIndex,
    GoRouter router,
    WidgetRef ref,
    ThemeData theme,
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
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color:
                  isSelected
                      ? Colors
                          .white // Siempre blanco cuando está seleccionado
                      : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(int index, GoRouter router, WidgetRef ref) {
    if (ref.read(dashboardIndexProvider) != index) {
      ref.read(dashboardIndexProvider.notifier).state = index;
      switch (index) {
        case 0:
          router.go('/chat');
          break;
        case 1:
          router.go('/favorites');
          break;
        case 2:
          router.go('/home');
          break;
        case 3:
          router.go('/cart');
          break;
        case 4:
          router.go('/profile');
          break;
      }
    }
  }
}
