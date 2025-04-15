import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/order.dart';
import 'package:bombastik/domain/repositories/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final ordersStreamProvider = StreamProvider<List<CommerceOrder>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('orders')
      .where('commerceId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CommerceOrder.fromMap({...doc.data(), 'id': doc.id}))
          .toList());
});

// Provider para filtrar pedidos por estado
final filteredOrdersProvider = Provider.family<AsyncValue<List<CommerceOrder>>, OrderStatus>((ref, status) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  
  return ordersAsync.when(
    data: (orders) {
      final filteredOrders = orders.where((order) => order.status == status).toList();
      return AsyncValue.data(filteredOrders);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Provider para contar pedidos por estado
final orderCountProvider = Provider.family<int, OrderStatus>((ref, status) {
  final ordersAsyncValue = ref.watch(ordersStreamProvider);
  
  return ordersAsyncValue.when(
    data: (orders) => orders.where((order) => order.status == status).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}); 