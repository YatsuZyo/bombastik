// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:bombastik/infrastructure/services/local_storage_service.dart';
import 'package:bombastik/presentation/providers/client-providers/profile/imgbb_service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/domain/repositories/profile_repository.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final Ref ref;
  final ProfileRepository _repository;
  bool _isInitialized = false;

  ProfileNotifier(this.ref, this._repository) : super(UserProfile.empty()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print('Cargando datos iniciales del perfil...'); // Deug
    try {
      final cachedPhotoUrl = await LocalStorageService.getPhotoUrl();

      // 2. Obtener datos de Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        print('Datos ANTES: ${state.phone}, ${state.address}');
        state = UserProfile.fromMap(data);
        print('Datos DESPUÉS: ${state.phone}, ${state.address}');
        print('Datos de Firestore: $data'); // Debug

        // 3. Actualizar estado con TODOS los campos
        state = UserProfile(
          uid: user.uid,
          email: data['email'] ?? user.email ?? '',
          name: data['name'] ?? user.displayName ?? '',
          phone: data['phone'] ?? state.phone,
          address: data['address'] ?? state.address,
          photoUrl: data['photoUrl'] ?? cachedPhotoUrl,
          role: data['role'] ?? 'cliente',
          createdAt: data['createdAt']?.toDate(),
        );

        // 4. Guardar en caché local si hay nueva foto
        if (data['photoUrl'] != null) {
          await LocalStorageService.savePhotoUrl(data['photoUrl']!);
        }
      } else {
        print('Documento de usuario no encontrado en Firestore');
      }
    } catch (e) {
      print('Error cargando datos iniciales: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<String?> uploadAndUpdateProfileImage(File imageFile) async {
    print('Subiendo imagen de perfil...'); // Debug
    try {
      final imageUrl = await _repository.uploadProfileImage(imageFile);
      if (imageUrl != null) {
        await updateProfileData({'photoUrl': imageUrl});
      }
      return imageUrl;
    } catch (e) {
      print('Error subiendo imagen: $e'); // Debug
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> newData) async {
    print('Actualizando perfil con: $newData'); // Debug
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Actualizar Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(newData);
      await _loadInitialData();

      // 2. Actualizar estado local
      state = state.copyWith(
        phone: newData['phone'] ?? state.phone,
        address: newData['address'] ?? state.address,
        photoUrl: newData['photoUrl'] ?? state.photoUrl,
      );

      // 3. Actualizar caché local solo si es la foto
      if (newData['photoUrl'] != null) {
        await LocalStorageService.savePhotoUrl(newData['photoUrl']!);
      }

      print('Perfil actualizado: ${state.toMapForFirestore()}'); // Debug
    } catch (e) {
      print('Error actualizando perfil: $e'); // Debug
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<String?> uploadImageWithConfirmation({
    required BuildContext context,
    required File imageFile,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar imagen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(imageFile, height: 200),
                const SizedBox(height: 20),
                const Text('¿Deseas usar esta imagen como foto de perfil?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final newUrl = await uploadAndUpdateProfileImage(imageFile);
        if (newUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil actualizada')),
          );
        }
        return newUrl;
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        return null;
      }
    }
    return null;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((
  ref,
) {
  final repository = ref.read(profileRepositoryProvider);
  return ProfileNotifier(ref, repository);
});
