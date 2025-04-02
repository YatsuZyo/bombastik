// lib/presentation/providers/cart/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem newItem) {
    final existingIndex = state.indexWhere((item) => item.id == newItem.id);

    if (existingIndex >= 0) {
      state =
          state
              .map(
                (item) =>
                    item.id == newItem.id
                        ? CartItem(
                          id: item.id,
                          name: item.name,
                          price: item.price,
                          quantity: item.quantity + 1,
                        )
                        : item,
              )
              .toList();
    } else {
      state = [...state, newItem];
    }
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    state = [
      for (final item in state)
        if (item.id == itemId) item..quantity = newQuantity else item,
    ];
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.total);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
