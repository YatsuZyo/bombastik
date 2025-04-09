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

final ordersStreamProvider = StreamProvider.autoDispose<List<CommerceOrder>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final commerceId = ref.watch(currentCommerceIdProvider);
  
  if (commerceId == null) return Stream.value([]);
  
  return repository.watchOrders(commerceId);
});

// Provider para filtrar pedidos por estado
final filteredOrdersProvider = Provider.family<List<CommerceOrder>, OrderStatus?>((ref, status) {
  final ordersAsyncValue = ref.watch(ordersStreamProvider);
  
  return ordersAsyncValue.when(
    data: (orders) {
      if (status == null) return orders;
      return orders.where((order) => order.status == status).toList();
    },
    loading: () => [],
    error: (_, __) => [],
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