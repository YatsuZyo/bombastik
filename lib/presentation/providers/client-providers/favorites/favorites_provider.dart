// lib/presentation/providers/favorites/favorites_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
      return FavoritesNotifier();
    });

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier()
    : super([
        'Producto 1',
        'Producto 2',
        'Producto 3',
        'Oferta especial',
        'Servicio premium',
      ]);

  void addFavorite(String item) {
    state = [...state, item];
  }

  void removeFavorite(String item) {
    state = state.where((element) => element != item).toList();
  }

  void clearFavorites() {
    state = [];
  }
}
