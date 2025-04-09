import 'package:cloud_firestore/cloud_firestore.dart';

enum PromotionType {
  percentage,    // Descuento porcentual
  fixedAmount,   // Descuento de monto fijo
  buyXGetY,      // Compra X lleva Y
  bundle         // Combo de productos
}

enum PromotionStatus {
  active,
  scheduled,
  expired,
  cancelled
}

class Promotion {
  final String? id;
  final String commerceId;
  final String title;
  final String description;
  final PromotionType type;
  final PromotionStatus status;
  final double value;        // Porcentaje o monto fijo del descuento
  final DateTime startDate;
  final DateTime endDate;
  final List<String> productIds; // IDs de productos aplicables
  final int? minQuantity;   // Cantidad mínima de productos
  final int? maxUses;       // Máximo de usos permitidos
  final int usedCount;      // Veces que se ha usado
  final double? minPurchaseAmount; // Monto mínimo de compra
  final String? imageUrl;   // Imagen promocional
  final Map<String, dynamic>? conditions; // Condiciones adicionales

  Promotion({
    this.id,
    required this.commerceId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.value,
    required this.startDate,
    required this.endDate,
    required this.productIds,
    this.minQuantity,
    this.maxUses,
    this.usedCount = 0,
    this.minPurchaseAmount,
    this.imageUrl,
    this.conditions,
  });

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'] as String?,
      commerceId: map['commerceId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: PromotionType.values.firstWhere(
        (e) => e.toString() == 'PromotionType.${map['type']}',
      ),
      status: PromotionStatus.values.firstWhere(
        (e) => e.toString() == 'PromotionStatus.${map['status']}',
      ),
      value: (map['value'] as num).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      productIds: List<String>.from(map['productIds'] as List),
      minQuantity: map['minQuantity'] as int?,
      maxUses: map['maxUses'] as int?,
      usedCount: map['usedCount'] as int? ?? 0,
      minPurchaseAmount: map['minPurchaseAmount'] != null 
        ? (map['minPurchaseAmount'] as num).toDouble()
        : null,
      imageUrl: map['imageUrl'] as String?,
      conditions: map['conditions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commerceId': commerceId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'value': value,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'productIds': productIds,
      'minQuantity': minQuantity,
      'maxUses': maxUses,
      'usedCount': usedCount,
      'minPurchaseAmount': minPurchaseAmount,
      'imageUrl': imageUrl,
      'conditions': conditions,
    };
  }

  Promotion copyWith({
    String? id,
    String? commerceId,
    String? title,
    String? description,
    PromotionType? type,
    PromotionStatus? status,
    double? value,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? productIds,
    int? minQuantity,
    int? maxUses,
    int? usedCount,
    double? minPurchaseAmount,
    String? imageUrl,
    Map<String, dynamic>? conditions,
  }) {
    return Promotion(
      id: id ?? this.id,
      commerceId: commerceId ?? this.commerceId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productIds: productIds ?? this.productIds,
      minQuantity: minQuantity ?? this.minQuantity,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      imageUrl: imageUrl ?? this.imageUrl,
      conditions: conditions ?? this.conditions,
    );
  }
} 