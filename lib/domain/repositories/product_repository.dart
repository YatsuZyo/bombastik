import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/domain/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(String commerceId);
  Stream<List<Product>> watchProducts(String commerceId);
  Future<Product?> getProduct(String productId);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<List<Product>> getProductsByCategory(String commerceId, ProductCategory category);
}

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProductRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<Product>> getProducts(String commerceId) async {
    try {
      print('Obteniendo productos para el comercio: $commerceId');
      final snapshot = await _firestore
          .collection('commerces')
          .doc(commerceId)
          .collection('products')
          .orderBy('name')
          .get();

      print('Número de productos encontrados: ${snapshot.docs.length}');
      
      final products = snapshot.docs
          .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
          
      print('Productos procesados: ${products.length}');
      return products;
    } catch (e) {
      print('Error al obtener productos: $e');
      throw Exception('Error al obtener productos: $e');
    }
  }

  @override
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore
          .collectionGroup('products')
          .where(FieldPath.documentId, isEqualTo: productId)
          .get();

      if (doc.docs.isEmpty) return null;

      return Product.fromMap({...doc.docs.first.data(), 'id': doc.docs.first.id});
    } catch (e) {
      throw Exception('Error al obtener el producto: $e');
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    try {
      await _firestore
          .collection('commerces')
          .doc(product.commerceId)
          .collection('products')
          .add(product.toMap());
    } catch (e) {
      throw Exception('Error al crear el producto: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('ID de producto no válido');
      }

      await _firestore
          .collection('commerces')
          .doc(product.commerceId)
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      throw Exception('Error al actualizar el producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await _firestore
          .collection('commerces')
          .doc(user.uid)
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String commerceId, 
    ProductCategory category
  ) async {
    try {
      final snapshot = await _firestore
          .collection('commerces')
          .doc(commerceId)
          .collection('products')
          .where('category', isEqualTo: category.toString().split('.').last)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  @override
  Stream<List<Product>> watchProducts(String commerceId) {
    return _firestore
        .collection('commerces')
        .doc(commerceId)
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }
} 