import 'dart:io';
import 'package:bombastik/domain/use_cases/product_controller.dart';
import 'package:bombastik/presentation/providers/client-providers/profile/imgbb_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/domain/models/products_state.dart';
import 'package:bombastik/domain/repositories/product_repository.dart';
import 'package:bombastik/infrastructure/services/imgbb_service.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    return ProductsNotifier(
      productRepository: ref.watch(productRepositoryProvider),
      imgbbService: ref.watch(imgBBServiceProvider),
    );
  },
);

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository _productRepository;
  final ImgBBService _imgbbService;

  ProductsNotifier({
    required ProductRepository productRepository,
    required ImgBBService imgbbService,
  }) : _productRepository = productRepository,
       _imgbbService = imgbbService,
       super(ProductsState());

  Future<void> createProduct(
    Product product,
    File imageFile,
    BuildContext context,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      // Subir imagen a ImgBB
      final imageUrl = await _imgbbService.uploadImage(imageFile);

      // Crear producto con la URL de la imagen
      final newProduct = product.copyWith(imageUrl: imageUrl);
      await _productRepository.createProduct(newProduct);

      // Actualizar estado
      final products = [...state.products, newProduct];
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(
    Product product,
    File? imageFile,
    BuildContext context,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      String? imageUrl = product.imageUrl;
      if (imageFile != null) {
        // Subir nueva imagen si se seleccionó una
        imageUrl = await _imgbbService.uploadImage(imageFile);
      }

      // Actualizar producto con la nueva URL de imagen si corresponde
      final updatedProduct = product.copyWith(imageUrl: imageUrl);
      await _productRepository.updateProduct(updatedProduct);

      // Actualizar estado
      final products =
          state.products.map((p) {
            return p.id == product.id ? updatedProduct : p;
          }).toList();

      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void setSelectedCategory(ProductCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
