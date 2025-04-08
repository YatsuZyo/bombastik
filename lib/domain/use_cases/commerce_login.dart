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

  CommerceLoginController(this._authService) : super(const AsyncValue.data(null));

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
        // Buscar el email asociado al RIF
        final commerceDoc = await _firestore
            .collection('commerces')
            .where('rif', isEqualTo: identifier)
            .get();

        if (commerceDoc.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'commerce-not-found',
            message: 'No se encontró un comercio con ese RIF',
          );
        }

        email = commerceDoc.docs.first.data()['email'] as String;
      }

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Verificar que el usuario es comercio
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['role'] == 'commerce') {
          state = const AsyncValue.data(null);
          GoRouter.of(context).pushReplacement('/commerce-home');
        } else {
          await _authService.signOut();
          throw FirebaseAuthException(
            code: 'invalid-role',
            message: 'Esta cuenta no es de comercio',
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