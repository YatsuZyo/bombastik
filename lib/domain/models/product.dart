import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  frutas,
  verduras,
  carnes,
  lacteos,
  panaderia,
  bebidas,
  snacks,
  limpieza,
  otros
}

class Product {
  final String? id;
  final String commerceId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final ProductCategory category;
  final String? imageUrl;
  final bool isPerishable;
  final DateTime? expirationDate;
  final String? storageConditions;
  final bool requiresRefrigeration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.commerceId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
    this.isPerishable = false,
    this.expirationDate,
    this.storageConditions,
    this.requiresRefrigeration = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'commerceId': commerceId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category.toString().split('.').last,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isPerishable': isPerishable,
      if (expirationDate != null) 'expirationDate': Timestamp.fromDate(expirationDate!),
      if (storageConditions != null) 'storageConditions': storageConditions,
      'requiresRefrigeration': requiresRefrigeration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Product(
      id: map['id'] as String?,
      commerceId: map['commerceId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      category: ProductCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => ProductCategory.otros,
      ),
      imageUrl: map['imageUrl'] as String?,
      isPerishable: map['isPerishable'] as bool? ?? false,
      expirationDate: map['expirationDate'] != null 
          ? parseDate(map['expirationDate'])
          : null,
      storageConditions: map['storageConditions'] as String?,
      requiresRefrigeration: map['requiresRefrigeration'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Product copyWith({
    String? id,
    String? commerceId,
    String? name,
    String? description,
    double? price,
    int? stock,
    ProductCategory? category,
    String? imageUrl,
    bool? isPerishable,
    DateTime? expirationDate,
    String? storageConditions,
    bool? requiresRefrigeration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      commerceId: commerceId ?? this.commerceId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isPerishable: isPerishable ?? this.isPerishable,
      expirationDate: expirationDate ?? this.expirationDate,
      storageConditions: storageConditions ?? this.storageConditions,
      requiresRefrigeration: requiresRefrigeration ?? this.requiresRefrigeration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 