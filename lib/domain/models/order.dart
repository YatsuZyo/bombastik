import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,    // Pedido realizado pero no aceptado
  accepted,   // Pedido aceptado por el comercio
  preparing,  // En preparación
  ready,      // Listo para entrega/recogida
  delivering, // En camino (si aplica)
  completed,  // Entregado y completado
  cancelled   // Cancelado
}

class CommerceOrder {
  final String id;
  final String commerceId;
  final String clientId;
  final String clientName;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? deliveryAddress;
  final bool isDelivery;

  CommerceOrder({
    required this.id,
    required this.commerceId,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.deliveryAddress,
    this.isDelivery = false,
  });

  factory CommerceOrder.fromMap(Map<String, dynamic> map) {
    return CommerceOrder(
      id: map['id'] as String,
      commerceId: map['commerceId'] as String,
      clientId: map['clientId'] as String,
      clientName: map['clientName'] as String,
      items: (map['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      total: (map['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'] as String?,
      deliveryAddress: map['deliveryAddress'] as String?,
      isDelivery: map['isDelivery'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commerceId': commerceId,
      'clientId': clientId,
      'clientName': clientName,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'deliveryAddress': deliveryAddress,
      'isDelivery': isDelivery,
    };
  }

  CommerceOrder copyWith({
    String? id,
    String? commerceId,
    String? clientId,
    String? clientName,
    List<OrderItem>? items,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? deliveryAddress,
    bool? isDelivery,
  }) {
    return CommerceOrder(
      id: id ?? this.id,
      commerceId: commerceId ?? this.commerceId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      isDelivery: isDelivery ?? this.isDelivery,
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? notes;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.notes,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      imageUrl: map['imageUrl'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? notes,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
} 