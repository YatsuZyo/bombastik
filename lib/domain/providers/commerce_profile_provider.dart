import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bombastik/domain/models/commerce_profile.dart';

part 'commerce_profile_provider.g.dart';

@Riverpod(keepAlive: true)
class CommerceProfileController extends _$CommerceProfileController {
  @override
  FutureOr<CommerceProfile?> build() async {
    debugPrint('CommerceProfileController: Iniciando build()');
    return _loadCommerceData();
  }

  Future<CommerceProfile?> _loadCommerceData() async {
    try {
      debugPrint('CommerceProfileController: Iniciando carga de datos');

      final user = FirebaseAuth.instance.currentUser;
      debugPrint(
        'CommerceProfileController: Usuario actual: ${user?.uid ?? "no hay usuario"}',
      );

      if (user == null) {
        debugPrint('CommerceProfileController: No hay usuario autenticado');
        return null;
      }

      debugPrint(
        'CommerceProfileController: Intentando obtener documento de Firestore para uid: ${user.uid}',
      );
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      debugPrint(
        'CommerceProfileController: ¿Documento existe?: ${doc.exists}',
      );

      if (!doc.exists) {
        debugPrint(
          'CommerceProfileController: No se encontró el documento del usuario',
        );
        return null;
      }

      final data = doc.data()!;
      
      // Verificar que es un comercio
      if (data['role'] != 'commerce') {
        debugPrint('CommerceProfileController: El usuario no es un comercio');
        throw Exception('Esta cuenta no es de comercio');
      }

      data['uid'] = user.uid;
      debugPrint('CommerceProfileController: Datos obtenidos: $data');

      debugPrint(
        'CommerceProfileController: Creando instancia de CommerceProfile',
      );
      final profile = CommerceProfile.fromMap(data);
      debugPrint('CommerceProfileController: Perfil cargado exitosamente');
      return profile;
    } catch (e, stackTrace) {
      debugPrint('CommerceProfileController: Error al cargar datos: $e');
      debugPrint('CommerceProfileController: StackTrace: $stackTrace');
      throw Exception('Error al cargar los datos: ${e.toString()}');
    }
  }

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadCommerceData());
  }

  Future<void> updateProfile(CommerceProfile updatedProfile) async {
    state = const AsyncValue.loading();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updatedProfile.toMap(), SetOptions(merge: true));

      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Error al actualizar el perfil: ${e.toString()}');
    }
  }

  Future<void> updateField(String field, dynamic value) async {
    state = const AsyncValue.loading();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({field: value});

      final currentProfile = state.value;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          companyName: field == 'companyName' ? value : null,
          rif: field == 'rif' ? value : null,
          email: field == 'email' ? value : null,
          phone: field == 'phone' ? value : null,
          address: field == 'address' ? value : null,
          category: field == 'category' ? value : null,
          isActive: field == 'isActive' ? value : null,
        );
        state = AsyncValue.data(updatedProfile);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
