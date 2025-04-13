import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum PromotionType {
  percentage, // Descuento porcentual
  fixedAmount, // Descuento de monto fijo
  buyXGetY, // Compra X lleva Y
  bundle, // Combo de productos
}

enum PromotionStatus { active, scheduled, expired, cancelled }

class Promotion {
  final String? id;
  final String commerceId;
  final String title;
  final String description;
  final PromotionType type;
  final PromotionStatus status;
  final double value; // Porcentaje o monto fijo del descuento
  final DateTime startDate;
  final DateTime endDate;
  final List<String> productIds; // IDs de productos aplicables
  final String? categoryId; // Nueva propiedad para categoría
  final double? minPurchaseAmount; // Monto mínimo de compra
  final int? maxUses; // Máximo de usos permitidos
  final int? usedCount; // Veces que se ha usado
  final String? imageUrl; // Imagen promocional
  final String? code; // Nueva propiedad para código promocional
  final Map<String, bool>?
  usedByCustomers; // Nueva propiedad para rastrear uso por cliente

  const Promotion({
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
    this.categoryId, // Opcional: puede ser por categoría o por productos
    this.minPurchaseAmount,
    this.maxUses,
    this.usedCount,
    this.imageUrl,
    this.code,
    this.usedByCustomers,
  });

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
    String? categoryId,
    double? minPurchaseAmount,
    int? maxUses,
    int? usedCount,
    String? imageUrl,
    String? code,
    Map<String, bool>? usedByCustomers,
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
      categoryId: categoryId ?? this.categoryId,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      imageUrl: imageUrl ?? this.imageUrl,
      code: code ?? this.code,
      usedByCustomers: usedByCustomers ?? this.usedByCustomers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commerceId': commerceId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'value': value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'productIds': productIds,
      'categoryId': categoryId,
      'minPurchaseAmount': minPurchaseAmount,
      'maxUses': maxUses,
      'usedCount': usedCount ?? 0,
      'imageUrl': imageUrl,
      'code': code,
      'usedByCustomers': usedByCustomers ?? {},
    };
  }

  factory Promotion.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint('Convirtiendo mapa a Promotion: $map');

      // Validar campos requeridos
      if (map['title'] == null ||
          map['description'] == null ||
          map['type'] == null ||
          map['status'] == null ||
          map['value'] == null ||
          map['startDate'] == null ||
          map['endDate'] == null) {
        throw Exception('Campos requeridos faltantes en la promoción');
      }

      // Convertir tipo y estado
      final typeString = map['type'].toString();
      final statusString = map['status'].toString();

      final type = PromotionType.values.firstWhere(
        (e) => e.toString() == typeString,
        orElse: () => PromotionType.percentage,
      );

      final status = PromotionStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => PromotionStatus.active,
      );

      // Convertir fechas
      DateTime startDate;
      DateTime endDate;
      try {
        startDate = DateTime.parse(map['startDate']);
        endDate = DateTime.parse(map['endDate']);
      } catch (e) {
        debugPrint('Error al parsear fechas: $e');
        startDate = DateTime.now();
        endDate = DateTime.now().add(const Duration(days: 7));
      }

      // Convertir lista de productos
      List<String> productIds;
      try {
        productIds = List<String>.from(map['productIds'] ?? []);
      } catch (e) {
        debugPrint('Error al convertir productIds: $e');
        productIds = [];
      }

      // Convertir mapa de clientes
      Map<String, bool>? usedByCustomers;
      try {
        usedByCustomers =
            map['usedByCustomers'] != null
                ? Map<String, bool>.from(map['usedByCustomers'])
                : null;
      } catch (e) {
        debugPrint('Error al convertir usedByCustomers: $e');
        usedByCustomers = null;
      }

      return Promotion(
        id: map['id'],
        commerceId: map['commerceId'],
        title: map['title'],
        description: map['description'],
        type: type,
        status: status,
        value: (map['value'] as num).toDouble(),
        startDate: startDate,
        endDate: endDate,
        productIds: productIds,
        categoryId: map['categoryId'],
        minPurchaseAmount: map['minPurchaseAmount']?.toDouble(),
        maxUses: map['maxUses']?.toInt(),
        usedCount: map['usedCount']?.toInt() ?? 0,
        imageUrl: map['imageUrl'],
        code: map['code'],
        usedByCustomers: usedByCustomers,
      );
    } catch (e) {
      debugPrint('Error al convertir mapa a Promotion: $e');
      rethrow;
    }
  }
}
