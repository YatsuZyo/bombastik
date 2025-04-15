import 'package:cloud_firestore/cloud_firestore.dart';

class CommerceStats {
  final String commerceId;
  final double totalSales;
  final int totalOrders;
  final int uniqueCustomers;
  final List<ProductStats> topProducts;
  final Map<String, double> salesByPeriod;
  final DateTime lastUpdated;

  CommerceStats({
    required this.commerceId,
    required this.totalSales,
    required this.totalOrders,
    required this.uniqueCustomers,
    required this.topProducts,
    required this.salesByPeriod,
    required this.lastUpdated,
  });

  factory CommerceStats.empty() {
    return CommerceStats(
      commerceId: '',
      totalSales: 0,
      totalOrders: 0,
      uniqueCustomers: 0,
      topProducts: [],
      salesByPeriod: {},
      lastUpdated: DateTime.now(),
    );
  }

  factory CommerceStats.fromMap(Map<String, dynamic> map) {
    return CommerceStats(
      commerceId: map['commerceId'] ?? '',
      totalSales: (map['totalSales'] ?? 0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      uniqueCustomers: map['uniqueCustomers'] ?? 0,
      topProducts: (map['topProducts'] as List?)
              ?.map((e) => ProductStats.fromMap(e))
              .toList() ??
          [],
      salesByPeriod: Map<String, double>.from(map['salesByPeriod'] ?? {}),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commerceId': commerceId,
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'uniqueCustomers': uniqueCustomers,
      'topProducts': topProducts.map((e) => e.toMap()).toList(),
      'salesByPeriod': salesByPeriod,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  CommerceStats copyWith({
    String? commerceId,
    double? totalSales,
    int? totalOrders,
    int? uniqueCustomers,
    List<ProductStats>? topProducts,
    Map<String, double>? salesByPeriod,
    DateTime? lastUpdated,
  }) {
    return CommerceStats(
      commerceId: commerceId ?? this.commerceId,
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
      uniqueCustomers: uniqueCustomers ?? this.uniqueCustomers,
      topProducts: topProducts ?? this.topProducts,
      salesByPeriod: salesByPeriod ?? this.salesByPeriod,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ProductStats {
  final String productId;
  final String name;
  final String? imageUrl;
  final int quantitySold;
  final double totalRevenue;

  ProductStats({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory ProductStats.fromMap(Map<String, dynamic> map) {
    return ProductStats(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      quantitySold: map['quantitySold'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'quantitySold': quantitySold,
      'totalRevenue': totalRevenue,
    };
  }

  ProductStats copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    int? quantitySold,
    double? totalRevenue,
  }) {
    return ProductStats(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      quantitySold: quantitySold ?? this.quantitySold,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
} 