// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/presentation/screens/client/components/custom_bottom_navbar.dart';
import 'package:bombastik/presentation/screens/client/components/exit_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/config/router/app_router.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  final Widget child;
  const ClientDashboard({super.key, required this.child});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    final shouldExit = await _showExitConfirmationDialog();
    return shouldExit;
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ExitConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit && mounted) {
          ref.read(appRouterProvider).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: widget.child,
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}
