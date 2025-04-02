// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
//import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ModeSelectorScreen extends ConsumerWidget {
  const ModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(appRouterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125),
        child: AppBar(
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Image.asset(
                'assets/images/BombastikBlancoSinFondoSized.png',
                height: 90,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '¿Como deseas continuar?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Puedes cambiar de un modo a otro siempre que quieras.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24.0),
                ModeCard(
                  imagePath: 'assets/images/icon_cliente_resized.png',
                  title: 'Seguir como cliente',
                  description:
                      '¡Navega a través de la app y encuentra las mejores ofertas!',
                  onTap: () {
                    router.push('/client-start');
                  },
                ),
                const SizedBox(height: 16.0),
                ModeCard(
                  imagePath: 'assets/images/icon_comercio.png',
                  title: 'Seguir como comercio',
                  description:
                      'Administra tu comercio y visualiza tu dashboard de órdenes.',
                  onTap: () {
                    router.push('/commerce-signin');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundImage: AssetImage(imagePath),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
