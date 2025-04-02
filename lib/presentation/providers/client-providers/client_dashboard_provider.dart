import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para el índice seleccionado
final dashboardIndexProvider = StateProvider<int>(
  (ref) => 2,
); // 2 = Home por defecto

// Provider para el controlador principal
final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
      return DashboardController();
    });

// Estado del dashboard (puedes expandirlo según necesidades)
class DashboardState {
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({this.isLoading = false, this.errorMessage});

  // Métodos copyWith para manejo inmutable del estado
  DashboardState copyWith({bool? isLoading, String? errorMessage}) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Controlador principal
class DashboardController extends StateNotifier<DashboardState> {
  DashboardController() : super(const DashboardState());

  // Actualiza el índice y puede incluir lógica adicional
  void updateIndex(int newIndex) {
    state = state.copyWith(isLoading: true);

    // Simulamos carga asíncrona
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(isLoading: false);
    });
  }

  // Método para manejar errores
  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  // Método para limpiar errores
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
