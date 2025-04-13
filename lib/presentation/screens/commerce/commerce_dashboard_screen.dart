import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/presentation/widgets/gradient_bottom_bar.dart';
import 'package:bombastik/domain/providers/commerce_profile_provider.dart';

class CommerceDashboard extends ConsumerStatefulWidget {
  final Widget child;

  const CommerceDashboard({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<CommerceDashboard> createState() => _CommerceDashboardState();
}

class _CommerceDashboardState extends ConsumerState<CommerceDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Actualizar el índice basado en la ruta actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      if (currentPath.contains('profile')) {
        setState(() => _selectedIndex = 1);
      } else {
        setState(() => _selectedIndex = 0);
      }
    });
  }

  void _onItemTapped(int index) async {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/commerce-home');
        break;
      case 1:
        // Asegurarnos de que el perfil esté cargado antes de navegar
        final profileAsync = ref.read(commerceProfileControllerProvider);
        if (profileAsync.hasValue && profileAsync.value != null) {
          context.go('/commerce-profile');
        } else {
          // Intentar cargar el perfil
          await ref.read(commerceProfileControllerProvider.notifier).refreshProfile();
          if (mounted) {
            final updatedProfile = ref.read(commerceProfileControllerProvider);
            if (updatedProfile.hasValue && updatedProfile.value != null) {
              context.go('/commerce-profile');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al cargar el perfil. Intente nuevamente.'),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() => _selectedIndex = 0);
            }
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: GradientBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isDarkMode: isDark,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
} 