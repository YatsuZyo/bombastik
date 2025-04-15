import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/commerce_stats.dart';
import 'package:intl/intl.dart';

abstract class StatsRepository {
  Stream<CommerceStats> watchStats(String commerceId);
  Future<CommerceStats> getStats(String commerceId);
  Future<CommerceStats> getStatsByPeriod(String commerceId, DateTime startDate, DateTime endDate);
  Future<List<ProductStats>> getTopProducts(String commerceId, {int limit = 5});
  Future<Map<String, double>> getSalesTrend(String commerceId, int days);
}

class StatsRepositoryImpl implements StatsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StatsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<CommerceStats> watchStats(String commerceId) {
    return _firestore
        .collection('commerce_stats')
        .doc(commerceId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return CommerceStats.empty();
      }
      return CommerceStats.fromMap(snapshot.data()!);
    });
  }

  @override
  Future<CommerceStats> getStats(String commerceId) async {
    final snapshot = await _firestore
        .collection('commerce_stats')
        .doc(commerceId)
        .get();

    if (!snapshot.exists) {
      return CommerceStats.empty();
    }

    return CommerceStats.fromMap(snapshot.data()!);
  }

  @override
  Future<CommerceStats> getStatsByPeriod(
    String commerceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('commerceId', isEqualTo: commerceId)
        .where('status', isEqualTo: 'completed')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .get();

    final orders = ordersSnapshot.docs;
    final totalSales = orders.fold<double>(
      0,
      (sum, doc) => sum + (doc.data()['total'] as num).toDouble(),
    );

    final uniqueCustomers = orders
        .map((doc) => doc.data()['userId'] as String)
        .toSet()
        .length;

    final productStats = <String, ProductStats>{};
    for (final order in orders) {
      final items = order.data()['items'] as List<dynamic>;
      for (final item in items) {
        final productId = item['productId'] as String;
        final quantity = item['quantity'] as int;
        final price = (item['price'] as num).toDouble();
        final name = item['name'] as String;
        final imageUrl = item['imageUrl'] as String?;

        productStats.update(
          productId,
          (stats) => ProductStats(
            productId: stats.productId,
            name: stats.name,
            imageUrl: stats.imageUrl,
            quantitySold: stats.quantitySold + quantity,
            totalRevenue: stats.totalRevenue + (price * quantity),
          ),
          ifAbsent: () => ProductStats(
            productId: productId,
            name: name,
            imageUrl: imageUrl,
            quantitySold: quantity,
            totalRevenue: price * quantity,
          ),
        );
      }
    }

    final topProducts = productStats.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return CommerceStats(
      commerceId: commerceId,
      totalSales: totalSales,
      totalOrders: orders.length,
      uniqueCustomers: uniqueCustomers,
      topProducts: topProducts.take(5).toList(),
      salesByPeriod: await _calculateSalesByPeriod(commerceId, startDate, endDate),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<List<ProductStats>> getTopProducts(String commerceId, {int limit = 5}) async {
    final stats = await getStats(commerceId);
    return stats.topProducts.take(limit).toList();
  }

  @override
  Future<Map<String, double>> getSalesTrend(String commerceId, int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('commerceId', isEqualTo: commerceId)
          .where('status', isEqualTo: 'completed')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();

      final salesByPeriod = <String, double>{};
      
      // Inicializar todos los días con 0
      for (int i = 0; i <= days; i++) {
        final date = endDate.subtract(Duration(days: days - i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        salesByPeriod[dateKey] = 0;
      }

      // Agregar las ventas
      for (final order in ordersSnapshot.docs) {
        final date = (order.data()['createdAt'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final total = (order.data()['total'] as num).toDouble();
        
        salesByPeriod.update(
          dateKey,
          (value) => value + total,
          ifAbsent: () => total,
        );
      }

      return salesByPeriod;
    } catch (e, stackTrace) {
      print('Error en getSalesTrend: $e\n$stackTrace');
      throw Exception('Error al obtener la tendencia de ventas: $e');
    }
  }

  Future<Map<String, double>> _calculateSalesByPeriod(
    String commerceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('commerceId', isEqualTo: commerceId)
          .where('status', isEqualTo: 'completed')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();

      final salesByPeriod = <String, double>{};
      
      // Inicializar todos los días con 0
      final days = endDate.difference(startDate).inDays;
      for (int i = 0; i <= days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        salesByPeriod[dateKey] = 0;
      }

      // Agregar las ventas
      for (final order in ordersSnapshot.docs) {
        final date = (order.data()['createdAt'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final total = (order.data()['total'] as num).toDouble();
        
        salesByPeriod.update(
          dateKey,
          (value) => value + total,
          ifAbsent: () => total,
        );
      }

      return salesByPeriod;
    } catch (e, stackTrace) {
      print('Error en _calculateSalesByPeriod: $e\n$stackTrace');
      throw Exception('Error al calcular las ventas por período: $e');
    }
  }
} 