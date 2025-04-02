import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bombastik/infrastructure/services/auth_service.dart';

final clientLoginControllerProvider =
    StateNotifierProvider<ClientLoginController, AsyncValue<void>>(
      (ref) => ClientLoginController(AuthService()),
    );

class ClientLoginController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  ClientLoginController(this._authService) : super(const AsyncValue.data(null));

  Future<void> loginCliente({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Verificar que el usuario es cliente
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists && userDoc.data()?['role'] == 'cliente') {
          state = const AsyncValue.data(null);
          GoRouter.of(context).pushReplacement('/home');
        } else {
          await _authService.signOut();
          throw FirebaseAuthException(
            code: 'invalid-role',
            message: 'Esta cuenta no es de cliente',
          );
        }
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
