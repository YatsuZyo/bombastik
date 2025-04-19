import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bombastik/domain/models/commerce.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider para el repositorio de comercios
final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  return CommerceRepository();
});

class CommerceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Commerce>> getCommerces() {
    return _firestore
        .collection('commerces')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Commerce.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  Stream<List<Commerce>> getCommercesByCategory(String category) {
    return _firestore
        .collection('commerces')
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Commerce.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  Future<List<Commerce>> getAllCommerces() async {
    final snapshot =
        await _firestore
            .collection('commerces')
            .where('isActive', isEqualTo: true)
            .get();

    return snapshot.docs
        .map((doc) => Commerce.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }
}

final commercesProvider = StreamProvider<List<Commerce>>((ref) {
  return ref.watch(commerceRepositoryProvider).getCommerces();
});

final commercesByCategoryProvider =
    StreamProvider.family<List<Commerce>, String>((ref, category) {
      return ref
          .watch(commerceRepositoryProvider)
          .getCommercesByCategory(category);
    });

// Estado de la pantalla principal
class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedLocation;
  final List<Commerce> commerces;
  final List<Commerce> filteredCommerces;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery,
    this.selectedCategory,
    this.selectedLocation,
    this.commerces = const [],
    this.filteredCommerces = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    String? selectedLocation,
    List<Commerce>? commerces,
    List<Commerce>? filteredCommerces,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      commerces: commerces ?? this.commerces,
      filteredCommerces: filteredCommerces ?? this.filteredCommerces,
    );
  }
}

// Provider para el estado de la pantalla principal
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(commerceRepositoryProvider));
});

class HomeNotifier extends StateNotifier<HomeState> {
  final CommerceRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState()) {
    _loadCommerces();
  }

  Future<void> _loadCommerces() async {
    try {
      state = state.copyWith(isLoading: true);
      final commerces = await _repository.getAllCommerces();
      state = state.copyWith(
        isLoading: false,
        commerces: commerces,
        filteredCommerces: _filterCommerces(commerces),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar comercios: $e',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredCommerces: _filterCommerces(state.commerces),
    );
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(
      selectedCategory: category,
      filteredCommerces: _filterCommerces(state.commerces),
    );
  }

  void setSelectedLocation(String? location) {
    state = state.copyWith(
      selectedLocation: location,
      filteredCommerces: _filterCommerces(state.commerces),
    );
  }

  List<Commerce> _filterCommerces(List<Commerce> commerces) {
    return commerces.where((commerce) {
      // Filtrar por búsqueda
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        final query = state.searchQuery!.toLowerCase();
        if (!commerce.name.toLowerCase().contains(query) &&
            !commerce.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtrar por categoría
      if (state.selectedCategory != null) {
        if (commerce.category != state.selectedCategory) {
          return false;
        }
      }

      // Filtrar por ubicación
      if (state.selectedLocation != null) {
        if (commerce.location != state.selectedLocation) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> refresh() async {
    await _loadCommerces();
  }
}
