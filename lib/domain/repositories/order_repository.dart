import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/domain/models/order.dart';

abstract class OrderRepository {
  Stream<List<CommerceOrder>> watchOrders(String commerceId);
  Future<List<CommerceOrder>> getOrders(String commerceId);
  Future<CommerceOrder?> getOrder(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> deleteOrder(String orderId);
}

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<CommerceOrder>> watchOrders(String commerceId) {
    return _firestore
        .collection('commerces')
        .doc(commerceId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommerceOrder.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<List<CommerceOrder>> getOrders(String commerceId) async {
    try {
      final snapshot = await _firestore
          .collection('commerces')
          .doc(commerceId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommerceOrder.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  @override
  Future<CommerceOrder?> getOrder(String orderId) async {
    try {
      final doc = await _firestore
          .collectionGroup('orders')
          .where(FieldPath.documentId, isEqualTo: orderId)
          .get();

      if (doc.docs.isEmpty) return null;

      return CommerceOrder.fromMap({...doc.docs.first.data(), 'id': doc.docs.first.id});
    } catch (e) {
      throw Exception('Error al obtener el pedido: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Primero necesitamos encontrar el pedido para obtener el commerceId
      final order = await getOrder(orderId);
      if (order == null) throw Exception('Pedido no encontrado');

      await _firestore
          .collection('commerces')
          .doc(order.commerceId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar el estado del pedido: $e');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Primero necesitamos encontrar el pedido para obtener el commerceId
      final order = await getOrder(orderId);
      if (order == null) throw Exception('Pedido no encontrado');

      await _firestore
          .collection('commerces')
          .doc(order.commerceId)
          .collection('orders')
          .doc(orderId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar el pedido: $e');
    }
  }
} 