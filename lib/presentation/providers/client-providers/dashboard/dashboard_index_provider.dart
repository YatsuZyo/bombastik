import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:go_router/go_router.dart';
import 'package:bombastik/config/router/app_router.dart';

final dashboardIndexProvider = StateProvider<int>((ref) {
  final router = ref.read(appRouterProvider);
  final location = router.routerDelegate.currentConfiguration.uri.path;

  switch (location) {
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
});
