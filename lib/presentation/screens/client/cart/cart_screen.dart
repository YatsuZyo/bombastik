// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/presentation/providers/client-providers/cart/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartProvider.notifier).totalAmount;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Mi Carrito',
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
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color:
                    theme.brightness == Brightness.dark
                        ? theme
                            .colorScheme
                            .primary // Verde en modo oscuro
                        : theme.colorScheme.onPrimary, // Blanco en modo claro
              ),
              onPressed: () => _showClearCartDialog(context, ref, theme),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                cartItems.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder:
                          (context, index) => _buildCartItem(
                            context,
                            ref,
                            cartItems[index],
                            theme,
                          ),
                    ),
          ),
          if (cartItems.isNotEmpty)
            _buildCheckoutSection(context, totalAmount, theme),
        ],
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
            Icons.shopping_cart,
            size: 128,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para continuar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleSmall),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: theme.colorScheme.onSurface),
                  onPressed:
                      () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.id, item.quantity - 1),
                ),
                Text(
                  item.quantity.toString(),
                  style: theme.textTheme.bodyMedium,
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                  onPressed:
                      () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.id, item.quantity + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    double totalAmount,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _showCheckoutDialog(context, theme),
            child: Text(
              'Pagar ahora',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Vaciar carrito', style: theme.textTheme.titleLarge),
            content: Text(
              '¿Estás seguro de que quieres vaciar tu carrito?',
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
                  ref.read(cartProvider.notifier).clearCart();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Carrito vaciado'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Vaciar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showCheckoutDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar compra', style: theme.textTheme.titleLarge),
            content: Text(
              '¿Deseas proceder con el pago?',
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra realizada con éxito'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Confirmar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
