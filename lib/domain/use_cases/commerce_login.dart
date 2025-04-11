import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bombastik/infrastructure/services/auth_service.dart';
import 'package:bombastik/domain/models/commerce_profile.dart';

final commerceLoginControllerProvider =
    StateNotifierProvider<CommerceLoginController, AsyncValue<void>>(
      (ref) => CommerceLoginController(AuthService()),
    );

class CommerceLoginController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CommerceLoginController(this._authService)
    : super(const AsyncValue.data(null));

  Future<void> loginCommerce({
    required String identifier,
    required String password,
    required BuildContext context,
    required bool isRif,
  }) async {
    state = const AsyncValue.loading();
    try {
      String email = identifier;

      if (isRif) {
        // Agregar la J al RIF si no la tiene
        final rif = identifier.startsWith('J') ? identifier : 'J$identifier';

        // Buscar en la colección users
        final querySnapshot =
            await _firestore
                .collection('users')
                .where('rif', isEqualTo: rif)
                .get();

        if (querySnapshot.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'commerce-not-found',
            message: 'No se encontró un comercio con ese RIF',
          );
        }

        // Verificar que el usuario es comercio
        final userData = querySnapshot.docs.first.data();
        if (userData['role'] != 'commerce') {
          throw FirebaseAuthException(
            code: 'invalid-role',
            message: 'Esta cuenta no es de comercio',
          );
        }

        email = userData['email'] as String;
      }

      // Intentar iniciar sesión con el email y contraseña
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        state = const AsyncValue.data(null);
        GoRouter.of(context).pushReplacement('/commerce-home');
      }
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
