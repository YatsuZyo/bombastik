// lib/presentation/screens/client/client_dashboard/chat_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Chat de Asistencia',
          style: theme.textTheme.titleLarge?.copyWith(
            color:
                theme.brightness == Brightness.dark
                    ? theme
                        .colorScheme
                        .primary // Verde en modo oscuro
                    : theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor:
            theme.brightness == Brightness.dark
                ? theme
                    .colorScheme
                    .surface // Color del AppBar en modo oscuro (darkSurface)
                : theme.colorScheme.primary, // Color normal en modo claro
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMessageTile(
            theme: theme,
            text: 'Hola, ¿en qué puedo ayudarte?',
            isSupport: true,
          ),
          _buildMessageTile(
            theme: theme,
            text: 'Quiero información sobre...',
            isSupport: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile({
    required ThemeData theme,
    required String text,
    required bool isSupport,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isSupport
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSupport
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color:
              isSupport
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
