// lib/infrastructure/routes/app_router.dart
import 'package:bombastik/presentation/screens/client/cart/cart_screen.dart';
import 'package:bombastik/presentation/screens/client/client_dashboard/home_screen.dart';
import 'package:bombastik/presentation/screens/client/client_signin_screen.dart';
import 'package:bombastik/presentation/screens/client/favorites/favorites_screen.dart';
import 'package:bombastik/presentation/screens/client/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bombastik/presentation/screens/splash_screen.dart';
import 'package:bombastik/presentation/screens/client/client_start_screen.dart';
import 'package:bombastik/presentation/screens/client/client_login_screen.dart';
import 'package:bombastik/presentation/screens/client/client_onboarding_start_screen.dart';
import 'package:bombastik/presentation/screens/client/client_dashboard/client_dashboard_screen.dart';
import 'package:bombastik/presentation/screens/commerce/commerce_login.dart';
import 'package:bombastik/presentation/screens/commerce/commerce_signin_screen.dart';
import 'package:bombastik/presentation/screens/mode_selector_screen.dart';
import 'package:bombastik/presentation/screens/client/chat/chat_screen.dart';
import 'package:bombastik/presentation/screens/commerce/commerce_home_screen.dart';
import 'package:bombastik/presentation/screens/commerce/products/products_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder:
            (context, state) =>
                MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/mode-selector',
        name: 'mode-selector',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ModeSelectorScreen(),
            ),
      ),
      GoRoute(
        path: '/client-start',
        name: 'client-start',
        pageBuilder:
            (context, state) =>
                MaterialPage(key: state.pageKey, child: const StartScreen()),
      ),
      GoRoute(
        path: '/client-login',
        name: 'client-login',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ClientLoginScreen(),
            ),
      ),
      GoRoute(
        path: '/client-signin',
        name: 'client-signin',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ClientSignInScreen(),
            ),
      ),
      GoRoute(
        path: '/onboard',
        name: 'onboard',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const OnboardingStartScreen(),
            ),
      ),
      ShellRoute(
        builder: (context, state, child) => ClientDashboard(child: child),
        routes: [
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ChatScreen(),
                ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const FavoritesScreen(),
                ),
          ),
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(), // Pantalla principal del dashboard
                ),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const CartScreen(),
                ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                ),
          ),
        ],
      ),
      GoRoute(
        path: '/commerce-login',
        name: 'commerce-login',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const CommerceLoginScreen(),
            ),
      ),
      GoRoute(
        path: '/commerce-signin',
        name: 'commerce-signin',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const CommerceSignInScreen(),
            ),
      ),
      GoRoute(
        path: '/commerce-home',
        name: 'commerce-home',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const CommerceHomeScreen(),
            ),
      ),
      GoRoute(
        path: '/commerce-products',
        name: 'commerce-products',
        pageBuilder:
            (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ProductsScreen(),
            ),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Ejemplo de lógica de redirección (ajustar según necesidades):
      // final isAuthenticated = ref.read(authProvider).isLoggedIn;
      // if (!isAuthenticated && !state.matchedLocation.startsWith('/login')) {
      //   return '/client-login';
      // }
      return null;
    },
  );
}
