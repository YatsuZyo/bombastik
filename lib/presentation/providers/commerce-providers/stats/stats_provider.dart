import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/models/commerce_stats.dart';
import '../../../../domain/repositories/stats_repository.dart';

// Provider para el repositorio de estadísticas
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepositoryImpl();
});

// Provider para el ID del comercio actual
final currentCommerceIdProvider = StateProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

// Provider para las estadísticas generales
final commerceStatsProvider = StreamProvider.autoDispose<CommerceStats>((ref) {
  final commerceId = ref.watch(currentCommerceIdProvider);
  if (commerceId == null) {
    return Stream.value(CommerceStats.empty());
  }
  return ref.watch(statsRepositoryProvider).watchStats(commerceId);
});

// Provider para las estadísticas por período
final commerceStatsByPeriodProvider = FutureProvider.autoDispose.family<CommerceStats, ({DateTime startDate, DateTime endDate})>((ref, period) async {
  final commerceId = ref.watch(currentCommerceIdProvider);
  if (commerceId == null) {
    return CommerceStats.empty();
  }
  return ref.watch(statsRepositoryProvider).getStatsByPeriod(
    commerceId,
    period.startDate,
    period.endDate,
  );
});

// Provider para los productos más vendidos
final topProductsProvider = FutureProvider.autoDispose<List<ProductStats>>((ref) async {
  final commerceId = ref.watch(currentCommerceIdProvider);
  if (commerceId == null) {
    return [];
  }
  return ref.watch(statsRepositoryProvider).getTopProducts(commerceId);
});

// Provider para la tendencia de ventas
final salesTrendProvider = FutureProvider.autoDispose.family<Map<String, double>, int>((ref, days) async {
  final repository = ref.watch(statsRepositoryProvider);
  final commerceId = ref.watch(currentCommerceIdProvider);

  if (commerceId == null) {
    throw Exception('No hay un comercio seleccionado');
  }

  try {
    final trend = await repository.getSalesTrend(commerceId, days);
    return trend;
  } catch (e, stack) {
    print('Error al obtener la tendencia de ventas: $e\n$stack');
    throw Exception('Error al obtener la tendencia de ventas');
  }
});

// Provider para el período seleccionado
final selectedPeriodProvider = StateProvider<({DateTime startDate, DateTime endDate})>((ref) {
  final now = DateTime.now();
  return (
    startDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30)),
    endDate: now,
  );
});

// Provider para actualizar el período seleccionado
final updateSelectedPeriodProvider = Provider<void Function(({DateTime startDate, DateTime endDate}))>((ref) {
  return (period) {
    ref.read(selectedPeriodProvider.notifier).state = period;
  };
});

// Provider para las estadísticas filtradas por el período seleccionado
final filteredStatsProvider = FutureProvider.autoDispose<CommerceStats>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final commerceId = ref.watch(currentCommerceIdProvider);
  
  if (commerceId == null) {
    return CommerceStats.empty();
  }
  
  try {
    return await ref.watch(statsRepositoryProvider).getStatsByPeriod(
      commerceId,
      period.startDate,
      period.endDate,
    );
  } catch (e) {
    // Si hay un error, retornamos estadísticas vacías
    return CommerceStats.empty();
  }
}); 