import 'package:bombastik/domain/models/product.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final ProductCategory? selectedCategory;
  final String searchQuery;

  ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery = '',
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    ProductCategory? selectedCategory,
    String? searchQuery,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
