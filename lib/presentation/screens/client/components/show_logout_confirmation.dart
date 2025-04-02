// lib/presentation/components/dialogs/show_logout_confirmation.dart
import 'package:flutter/material.dart';

Future<bool> showLogoutConfirmation({
  required BuildContext context,
  required VoidCallback onLogout,
}) async {
  final theme = Theme.of(context);

  return await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Cerrar sesión',
                style: theme.textTheme.headlineMedium,
              ),
              // ignore: deprecated_member_use
              backgroundColor: theme.colorScheme.background,
              content: Text(
                '¿Estás seguro de que quieres cerrar sesión?',
                style: theme.textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancelar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onLogout();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Cerrar sesión',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
      ) ??
      false; // Retorna false si el diálogo es descartado
}
