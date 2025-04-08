import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/domain/repositories/product_repository.dart';
import 'package:bombastik/infrastructure/services/imgbb_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final imgBBServiceProvider = Provider<ImgBBService>((ref) {
  return ImgBBService(
    apiKey: '9106f089320713928b1662d1c6fdafab',
  );
});

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
      return ProductsNotifier(
        ref.read(productRepositoryProvider),
        ref.read(imgBBServiceProvider),
      );
    });

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  final ImgBBService _imgBBService;
  String? _currentCommerceId;

  ProductsNotifier(this._repository, this._imgBBService)
    : super(const AsyncValue.loading());

  void setCommerceId(String commerceId) {
    _currentCommerceId = commerceId;
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_currentCommerceId == null) return;

    try {
      state = const AsyncValue.loading();
      final products = await _repository.getProducts(_currentCommerceId!);
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createProduct(
    Product product,
    File imageFile,
    BuildContext context,
  ) async {
    if (_currentCommerceId == null) return;

    try {
      // 1. Subir imagen a ImgBB
      final imageUrl = await _imgBBService.uploadProductImage(imageFile);
      if (imageUrl == null) throw Exception('Error al subir la imagen');

      // 2. Crear producto con la URL de la imagen
      final newProduct = product.copyWith(
        imageUrl: imageUrl,
        commerceId: _currentCommerceId,
      );
      await _repository.createProduct(newProduct);

      // 3. Recargar productos
      await loadProducts();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear producto: $e')));
      }
    }
  }

  Future<void> updateProduct(
    Product product,
    File? imageFile,
    BuildContext context,
  ) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        // 1. Subir nueva imagen si se proporcionó una
        imageUrl = await _imgBBService.uploadProductImage(imageFile);
        if (imageUrl == null) throw Exception('Error al subir la imagen');
      }

      // 2. Actualizar producto con la nueva URL de imagen si existe
      final updatedProduct =
          imageUrl != null ? product.copyWith(imageUrl: imageUrl) : product;

      await _repository.updateProduct(updatedProduct);

      // 3. Recargar productos
      await loadProducts();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar producto: $e')),
        );
      }
    }
  }

  Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      await _repository.deleteProduct(productId);
      
      // Actualizar el estado después de eliminar
      if (_currentCommerceId != null) {
        final products = await _repository.getProducts(_currentCommerceId!);
        state = AsyncValue.data(products);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado exitosamente')),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar producto: $e')),
        );
      }
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
