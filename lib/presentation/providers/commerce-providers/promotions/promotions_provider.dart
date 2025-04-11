import 'package:bombastik/presentation/providers/products_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/promotion.dart';
import 'package:bombastik/domain/repositories/promotion_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:bombastik/infrastructure/services/auth_service.dart';

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final promotionsStreamProvider = StreamProvider.autoDispose<List<Promotion>>((
  ref,
) {
  final repository = ref.watch(promotionRepositoryProvider);
  final commerceId = ref.watch(currentCommerceIdProvider);

  print('CommerceId actual: $commerceId');

  if (commerceId == null) {
    print('CommerceId es null, retornando lista vacía');
    return Stream.value([]);
  }

  try {
    return repository.watchPromotions(commerceId).handleError((error) {
      print('Error en watchPromotions: $error');
      return Stream.value([]);
    });
  } catch (e) {
    print('Excepción en promotionsStreamProvider: $e');
    return Stream.value([]);
  }
});

// Provider para filtrar promociones por estado
final filteredPromotionsProvider =
    Provider.family<List<Promotion>, PromotionStatus?>((ref, status) {
      final promotionsAsyncValue = ref.watch(promotionsStreamProvider);

      return promotionsAsyncValue.when(
        data: (promotions) {
          if (status == null) return promotions;
          return promotions.where((promo) => promo.status == status).toList();
        },
        loading: () => [],
        error: (error, stackTrace) {
          print('Error en filteredPromotionsProvider: $error');
          return [];
        },
      );
    });

// Provider para obtener promociones activas
final activePromotionsProvider = Provider<List<Promotion>>((ref) {
  final promotionsAsyncValue = ref.watch(promotionsStreamProvider);

  return promotionsAsyncValue.when(
    data: (promotions) {
      final now = DateTime.now();
      return promotions.where((promo) {
        return promo.status == PromotionStatus.active &&
            promo.startDate.isBefore(now) &&
            promo.endDate.isAfter(now);
      }).toList();
    },
    loading: () => [],
    error: (error, stackTrace) {
      print('Error en activePromotionsProvider: $error');
      return [];
    },
  );
});

// Provider para obtener promociones por producto
final productPromotionsProvider = Provider.family<List<Promotion>, String>((
  ref,
  productId,
) {
  final promotionsAsyncValue = ref.watch(promotionsStreamProvider);
  final productsState = ref.watch(productsProvider);

  return promotionsAsyncValue.when(
    data: (promotions) {
      final now = DateTime.now();
      return promotions.where((promo) {
        if (promo.status != PromotionStatus.active ||
            !promo.startDate.isBefore(now) ||
            !promo.endDate.isAfter(now)) {
          return false;
        }

        if (promo.productIds.contains(productId)) {
          return true;
        }

        if (promo.categoryId != null) {
          return productsState.products.any((p) =>
              p.id == productId &&
              p.category.toString().split('.').last == promo.categoryId);
        }

        return false;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider para verificar si un cliente puede usar una promoción
final canUsePromotionProvider = FutureProvider.family<bool, String>((
  ref,
  promotionId,
) async {
  final repository = ref.watch(promotionRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final user = await authService.getCurrentUser();
  
  if (user == null) return false;
  return await repository.canUsePromotion(promotionId, user.uid);
});

// Provider para marcar una promoción como usada
final usePromotionProvider = FutureProvider.family<void, String>((
  ref,
  promotionId,
) async {
  final repository = ref.watch(promotionRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final user = await authService.getCurrentUser();
  
  if (user == null) throw Exception('Cliente no autenticado');
  await repository.markPromotionAsUsed(promotionId, user.uid);
});
