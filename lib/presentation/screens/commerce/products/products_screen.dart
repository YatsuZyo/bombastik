import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:bombastik/presentation/screens/commerce/products/product_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/presentation/screens/commerce/promotions/promotions_screen.dart';
import 'package:bombastik/presentation/widgets/gradient_app_bar.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/presentation/widgets/gradient_card.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  ProductCategory? _selectedCategory;

  // Mapa de iconos para categorías
  final Map<ProductCategory, IconData> categoryIcons = {
    ProductCategory.frutas: Icons.apple,
    ProductCategory.verduras: Icons.eco,
    ProductCategory.carnes: Icons.restaurant_menu,
    ProductCategory.lacteos: Icons.egg,
    ProductCategory.panaderia: Icons.bakery_dining,
    ProductCategory.bebidas: Icons.local_drink,
    ProductCategory.snacks: Icons.cookie,
    ProductCategory.limpieza: Icons.cleaning_services,
    ProductCategory.otros: Icons.category,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        ref.read(currentCommerceIdProvider.notifier).state = user.uid;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsAsync = ref.watch(productsStreamProvider);
    final router = ref.read(appRouterProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Mis Productos',
        isDarkMode: isDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer),
            tooltip: 'Promociones',
            onPressed: () => router.push('/commerce-promotions'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar producto',
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(child: Text('Error: $error')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No hay productos registrados'),
                  );
                }

                final filteredProducts =
                    _selectedCategory != null
                        ? products
                            .where((p) => p.category == _selectedCategory)
                            .toList()
                        : products;

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GradientCard(
                        isDarkMode: isDark,
                        customGradient:
                            isDark
                                ? [
                                  AppColors.productsDarkGradientStart,
                                  AppColors.productsDarkGradientEnd,
                                ]
                                : [
                                  AppColors.productsGradientStart,
                                  AppColors.productsGradientEnd,
                                ],
                        builder:
                            (iconColor, titleColor, textColor) => ListTile(
                              leading:
                                  product.imageUrl != null
                                      ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          product.imageUrl!,
                                        ),
                                      )
                                      : CircleAvatar(
                                        child: Icon(
                                          Icons.shopping_bag,
                                          color: iconColor,
                                        ),
                                      ),
                              title: Text(
                                product.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${product.price.toStringAsFixed(2)}\$ - Stock: ${product.stock}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: iconColor),
                                    onPressed:
                                        () => _showEditProductDialog(
                                          context,
                                          product,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: iconColor),
                                    onPressed:
                                        () => _showDeleteConfirmation(
                                          context,
                                          product,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? colors.surface : colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.onSurface.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colors.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary),
                ),
                filled: true,
                fillColor: isDarkMode ? colors.surface : colors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              onChanged: (value) {
                // Implementar búsqueda
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.outline),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? colors.surface : colors.background,
                  ),
                ),
              ),
              child: DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: colors.primary),
                dropdownColor: isDarkMode ? colors.surface : colors.background,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.outline.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? colors.surface : colors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                menuMaxHeight: 300,
                borderRadius: BorderRadius.circular(12),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.all_inclusive,
                            color: colors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Todas',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...ProductCategory.values.map((category) {
                    final name = category.toString().split('.').last;
                    final capitalizedName =
                        name[0].toUpperCase() + name.substring(1);
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              categoryIcons[category] ?? Icons.category,
                              color: colors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              capitalizedName,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (ProductCategory? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProductFormDialog(),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Producto'),
            content: Text(
              '¿Estás seguro de eliminar el producto ${product.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(productRepositoryProvider)
                      .deleteProduct(product.id!);
                  Navigator.pop(context);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
