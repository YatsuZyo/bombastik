import 'package:bombastik/domain/models/commerce_profile.dart';
import 'package:bombastik/infrastructure/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommerceRepository {
  final FirestoreService _firestoreService;

  CommerceRepository(this._firestoreService);

  Future<void> createCommerce(CommerceProfile commerce) async {
    try {
      await _firestoreService.setDocument(
        collection: 'users',
        id: commerce.uid!,
        data: commerce.toMap(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CommerceProfile?> getCommerce(String userId) async {
    final doc = await _firestoreService.getDocument('users', userId);
    if (!doc.exists) return null;

    final data = doc.data();
    if (data is! Map<String, dynamic>) {
      throw FormatException('Document data is not a Map<String, dynamic>');
    }
    return CommerceProfile.fromMap(data);
  }

  Future<void> updateCommerce(CommerceProfile commerce) async {
    await _firestoreService.setDocument(
      collection: 'users',
      id: commerce.uid!,
      data: commerce.toMap(),
    );
  }

  Future<void> deactivateCommerce(String uid) async {
    await _firestoreService.setDocument(
      collection: 'users',
      id: uid,
      data: {'isActive': false, 'deletedAt': FieldValue.serverTimestamp()},
    );
  }
} 