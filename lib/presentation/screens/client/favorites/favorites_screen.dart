// ignore_for_file: deprecated_member_use

//import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/presentation/providers/client-providers/favorites/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);

    void removeFavorite(String item) {
      ref.read(favoritesProvider.notifier).removeFavorite(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$item" eliminado de favoritos'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    void clearAllFavorites() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Eliminar todos', style: theme.textTheme.titleLarge),
              content: Text(
                '¿Quieres eliminar todos tus favoritos?',
                style: theme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(favoritesProvider.notifier).clearFavorites();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favoritos eliminados'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Eliminar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Mis Favoritos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, // Mismo peso que en otras pantallas
            color:
                theme.brightness == Brightness.dark
                    ? theme
                        .colorScheme
                        .primary // Verde en modo oscuro
                    : theme.colorScheme.onPrimary, // Blanco en modo claro
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor:
            theme.brightness == Brightness.dark
                ? theme
                    .colorScheme
                    .surface // Color del AppBar en modo oscuro
                : theme.colorScheme.primary, // Color normal en modo claro
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_sweep_outlined,
              size: 30,
              color:
                  theme.brightness == Brightness.dark
                      ? theme
                          .colorScheme
                          .primary // Verde en modo oscuro
                      : theme.colorScheme.onPrimary, // Blanco en modo claro
            ),
            onPressed: clearAllFavorites,
          ),
        ],
      ),
      body:
          favorites.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder:
                    (context, index) => _buildFavoriteItem(
                      favorites[index],
                      () => removeFavorite(favorites[index]),
                      theme,
                    ),
              ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes favoritos aún',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el corazón en los productos para agregarlos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(
    String item,
    VoidCallback onRemove,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.favorite, color: theme.colorScheme.primary),
        title: Text(item, style: theme.textTheme.bodyLarge),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
