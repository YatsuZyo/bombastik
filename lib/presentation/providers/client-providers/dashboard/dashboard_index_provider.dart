import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/config/router/app_router.dart';

final dashboardIndexProvider =
    StateNotifierProvider<DashboardIndexNotifier, int>((ref) {
      final router = ref.watch(appRouterProvider);
      return DashboardIndexNotifier(router);
    });

class DashboardIndexNotifier extends StateNotifier<int> {
  final GoRouter router;

  DashboardIndexNotifier(this.router) : super(_getInitialIndex(router)) {
    // Escuchar cambios en la ruta
    router.routerDelegate.addListener(_handleRouteChange);
  }

  static int _getInitialIndex(GoRouter router) {
    final location = router.routerDelegate.currentConfiguration.uri.path;
    return _getIndexFromPath(location);
  }

  static int _getIndexFromPath(String path) {
    switch (path) {
      case '/chat':
        return 0;
      case '/favorites':
        return 1;
      case '/home':
        return 2;
      case '/cart':
        return 3;
      case '/profile':
        return 4;
      default:
        return 2; // Home como valor por defecto
    }
  }

  void _handleRouteChange() {
    final location = router.routerDelegate.currentConfiguration.uri.path;
    state = _getIndexFromPath(location);
  }

  void setIndex(int index) {
    String path;
    switch (index) {
      case 0:
        path = '/chat';
        break;
      case 1:
        path = '/favorites';
        break;
      case 2:
        path = '/home';
        break;
      case 3:
        path = '/cart';
        break;
      case 4:
        path = '/profile';
        break;
      default:
        path = '/home';
    }
    router.go(path);
    state = index;
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_handleRouteChange);
    super.dispose();
  }
}
