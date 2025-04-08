import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/domain/repositories/product_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final productControllerProvider =
    StateNotifierProvider<ProductController, AsyncValue<List<Product>>>((ref) {
      return ProductController(ref.watch(productRepositoryProvider));
    });

class ProductController extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  String? _currentCommerceId;

  ProductController(this._repository) : super(const AsyncValue.loading());

  void setCommerceId(String commerceId) {
    _currentCommerceId = commerceId;
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_currentCommerceId == null) return;

    state = const AsyncValue.loading();
    try {
      final products = await _repository.getProducts(_currentCommerceId!);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      await _repository.createProduct(product);
      await loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      await loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      await loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    if (_currentCommerceId == null) return [];
    return await _repository.getProductsByCategory(
      _currentCommerceId!,
      category,
    );
  }
}
