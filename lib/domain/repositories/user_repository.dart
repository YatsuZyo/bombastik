// ignore_for_file: avoid_print

import 'package:bombastik/domain/models/user_profile.dart';
import 'package:bombastik/infrastructure/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository(this._firestoreService);

  Future<void> createUser(UserProfile user) async {
    try {
      print('Intentando crear usuario en Firestore con uid: ${user.uid}');
      await _firestoreService.setDocument(
        collection: 'users',
        id: user.uid!,
        data: user.toMapForFirestore(),
      );
      print('Usuario creado exitosamente en Firestore');
    } catch (e) {
      print('Error al crear usuario en Firestore: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUser(String userId) async {
    final doc = await _firestoreService.getDocument('users', userId);
    if (!doc.exists) return null;

    final data = doc.data();
    if (data is! Map<String, dynamic>) {
      throw FormatException('Document data is not a Map<String, dynamic>');
    }
    return UserProfile.fromMap(data);
  }

  Future<void> updateUser(UserProfile user) async {
    await _firestoreService.setDocument(
      collection: 'users',
      id: user.uid!,
      data: user.toMapForFirestore(),
    );
  }

  Future<void> deactivateUser(String uid) async {
    await _firestoreService.setDocument(
      collection: 'users',
      id: uid,
      data: {'isActive': false, 'deletedAt': FieldValue.serverTimestamp()},
    );
  }
}
