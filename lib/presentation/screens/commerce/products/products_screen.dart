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
import 'package:google_fonts/google_fonts.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  ProductCategory? _selectedCategory;

  // Mapa de iconos y colores para categorías
  final Map<ProductCategory, Map<String, dynamic>> categoryStyles = {
    ProductCategory.frutas: {
      'icon': Icons.apple,
      'color': Colors.red,
      'gradient': [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
    },
    ProductCategory.verduras: {
      'icon': Icons.eco,
      'color': Colors.green,
      'gradient': [Color(0xFF96E6A1), Color(0xFFD4FC79)],
    },
    ProductCategory.carnes: {
      'icon': Icons.restaurant_menu,
      'color': Colors.brown,
      'gradient': [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    },
    ProductCategory.lacteos: {
      'icon': Icons.egg,
      'color': Colors.amber,
      'gradient': [Color(0xFFFFF1EB), Color(0xFFACE0F9)],
    },
    ProductCategory.panaderia: {
      'icon': Icons.bakery_dining,
      'color': Colors.orange,
      'gradient': [Color(0xFFFAD961), Color(0xFFF76B1C)],
    },
    ProductCategory.bebidas: {
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'gradient': [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    },
    ProductCategory.snacks: {
      'icon': Icons.cookie,
      'color': Colors.purple,
      'gradient': [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
    },
    ProductCategory.limpieza: {
      'icon': Icons.cleaning_services,
      'color': Colors.cyan,
      'gradient': [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    },
    ProductCategory.otros: {
      'icon': Icons.category,
      'color': Colors.grey,
      'gradient': [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
    },
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Mis Productos',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark ? [
                  AppColors.statsGradientDarkStart,
                  AppColors.statsGradientDarkEnd,
                ] : [
                  AppColors.statsGradientStart,
                  AppColors.statsGradientEnd,
                ],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.local_offer, color: Colors.white),
              tooltip: 'Promociones',
              onPressed: () => router.push('/commerce-promotions'),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              tooltip: 'Agregar producto',
              onPressed: () => _showAddProductDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                indicatorColor: theme.colorScheme.primary,
                dividerColor: Colors.transparent,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle),
                        const SizedBox(width: 8),
                        Text(
                          'Activos',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_off),
                        const SizedBox(width: 8),
                        Text(
                          'Deshabilitados',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildFilterSection(context),
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(child: Text('Error: $error')),
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos registrados',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Separar productos activos y deshabilitados
                  final now = DateTime.now();
                  final activeProducts =
                      products.where((p) {
                        if (!p.isPerishable) return true;
                        return p.expirationDate == null ||
                            p.expirationDate!.isAfter(now);
                      }).toList();

                  final disabledProducts =
                      products.where((p) {
                        if (!p.isPerishable) return false;
                        return p.expirationDate != null &&
                            p.expirationDate!.isBefore(now);
                      }).toList();

                  return TabBarView(
                    children: [
                      _buildProductList(
                        context,
                        activeProducts,
                        isDark,
                        theme,
                        isDisabled: false,
                      ),
                      _buildProductList(
                        context,
                        disabledProducts,
                        isDark,
                        theme,
                        isDisabled: true,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.1),
            colors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: GoogleFonts.poppins(
                  color: colors.onSurface.withOpacity(0.7),
                ),
                prefixIcon: Icon(Icons.search, color: colors.primary),
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
              style: GoogleFonts.poppins(color: colors.onSurface),
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
                          style: GoogleFonts.poppins(
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
                    final style = categoryStyles[category]!;
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: style['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              style['icon'],
                              color: style['color'],
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              capitalizedName,
                              style: GoogleFonts.poppins(
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

  Widget _buildProductList(
    BuildContext context,
    List<Product> products,
    bool isDark,
    ThemeData theme, {
    bool isDisabled = false,
  }) {
    final filteredProducts =
        _selectedCategory != null
            ? products.where((p) => p.category == _selectedCategory)
            : products;

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts.elementAt(index);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GradientCard(
            isDarkMode: isDark,
            customGradient:
                isDisabled
                    ? [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.1),
                    ]
                    : isDark
                    ? (categoryStyles[product.category]?['gradient']
                                as List<Color>?)
                            ?.map((color) => color.withOpacity(0.3))
                            .toList() ??
                        [Colors.grey.shade300, Colors.grey.shade100]
                    : categoryStyles[product.category]?['gradient']
                            as List<Color>? ??
                        [Colors.grey.shade300, Colors.grey.shade100],
            builder:
                (iconColor, titleColor, textColor) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                isDisabled
                                    ? Colors.grey.withOpacity(0.2)
                                    : (categoryStyles[product
                                                    .category]?['color']
                                                as Color?)
                                            ?.withOpacity(0.2) ??
                                        Colors.grey.withOpacity(0.2),
                            backgroundImage:
                                product.imageUrl != null
                                    ? NetworkImage(product.imageUrl!)
                                    : null,
                            child:
                                product.imageUrl == null
                                    ? Icon(
                                      categoryStyles[product.category]?['icon']
                                              as IconData? ??
                                          Icons.shopping_bag,
                                      color:
                                          isDisabled
                                              ? Colors.grey
                                              : (categoryStyles[product
                                                          .category]?['color']
                                                      as Color?) ??
                                                  iconColor,
                                      size: 24,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDisabled
                                            ? Colors.grey
                                            : isDark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.price.toStringAsFixed(2)}\$',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDisabled
                                            ? Colors.grey
                                            : isDark
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.black87.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  'Stock: ${product.stock}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        isDisabled
                                            ? Colors.grey
                                            : isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.black87.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isDisabled)
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                  onPressed:
                                      () =>
                                          _showReenableDialog(context, product),
                                ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                onPressed:
                                    () => _showEditProductDialog(
                                      context,
                                      product,
                                    ),
                              ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                                onPressed:
                                    () => _showDeleteConfirmation(
                                      context,
                                      product,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (product.isPerishable &&
                          product.expirationDate != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDisabled
                                    ? Colors.grey.withOpacity(0.1)
                                    : isDark
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.orange.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isDisabled
                                      ? Colors.grey.withOpacity(0.3)
                                      : isDark
                                      ? Colors.orange.withOpacity(0.3)
                                      : Colors.orange.shade400,
                              width: isDark ? 1.5 : 2.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color:
                                    isDisabled
                                        ? Colors.grey
                                        : isDark
                                        ? Colors.orange
                                        : Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Vence: ${_formatDate(product.expirationDate!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color:
                                      isDisabled
                                          ? Colors.grey
                                          : isDark
                                          ? Colors.orange
                                          : Colors.orange.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          ),
        );
      },
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

  void _showReenableDialog(BuildContext context, Product product) {
    final dialogContext = context;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rehabilitar Producto'),
            content: Text(
              '¿Deseas habilitar el producto ${product.name} nuevamente?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(productRepositoryProvider)
                        .updateProduct(
                          product.copyWith(
                            expirationDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          ),
                        );
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (!dialogContext.mounted) return;
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Producto ${product.name} habilitado nuevamente',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (!dialogContext.mounted) return;
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Error al habilitar el producto: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Habilitar'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
