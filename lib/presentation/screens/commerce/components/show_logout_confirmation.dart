import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/infrastructure/services/auth_service.dart';

Future<bool> showCommerceLogoutConfirmation({
  required BuildContext context,
  required VoidCallback onLogout,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        '¿Cerrar sesión?',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        '¿Estás seguro de que deseas cerrar sesión?',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            await AuthService().signOut();
            Navigator.of(context).pop(true);
            onLogout();
          },
          child: Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  return shouldLogout ?? false;
} 