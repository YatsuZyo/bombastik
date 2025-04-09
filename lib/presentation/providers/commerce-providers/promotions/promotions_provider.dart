import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/promotion.dart';
import 'package:bombastik/domain/repositories/promotion_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final promotionsStreamProvider = StreamProvider.autoDispose<List<Promotion>>((ref) {
  final repository = ref.watch(promotionRepositoryProvider);
  final commerceId = ref.watch(currentCommerceIdProvider);
  
  if (commerceId == null) return Stream.value([]);
  
  return repository.watchPromotions(commerceId);
});

// Provider para filtrar promociones por estado
final filteredPromotionsProvider = Provider.family<List<Promotion>, PromotionStatus?>((ref, status) {
  final promotionsAsyncValue = ref.watch(promotionsStreamProvider);
  
  return promotionsAsyncValue.when(
    data: (promotions) {
      if (status == null) return promotions;
      return promotions.where((promo) => promo.status == status).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider para obtener promociones activas
final activePromotionsProvider = Provider<List<Promotion>>((ref) {
  final promotionsAsyncValue = ref.watch(promotionsStreamProvider);
  
  return promotionsAsyncValue.when(
    data: (promotions) {
      final now = DateTime.now();
      return promotions.where((promo) => 
        promo.status == PromotionStatus.active &&
        promo.startDate.isBefore(now) &&
        promo.endDate.isAfter(now)
      ).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider para obtener promociones por producto
final productPromotionsProvider = Provider.family<List<Promotion>, String>((ref, productId) {
  final promotionsAsyncValue = ref.watch(promotionsStreamProvider);
  
  return promotionsAsyncValue.when(
    data: (promotions) {
      final now = DateTime.now();
      return promotions.where((promo) => 
        promo.status == PromotionStatus.active &&
        promo.startDate.isBefore(now) &&
        promo.endDate.isAfter(now) &&
        promo.productIds.contains(productId)
      ).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}); 