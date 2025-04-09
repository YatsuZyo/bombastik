import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/domain/models/promotion.dart';

abstract class PromotionRepository {
  Stream<List<Promotion>> watchPromotions(String commerceId);
  Future<List<Promotion>> getPromotions(String commerceId);
  Future<Promotion?> getPromotion(String promotionId);
  Future<void> createPromotion(Promotion promotion);
  Future<void> updatePromotion(Promotion promotion);
  Future<void> deletePromotion(String promotionId);
  Future<void> updatePromotionStatus(String promotionId, PromotionStatus status);
  Future<void> incrementUsedCount(String promotionId);
}

class PromotionRepositoryImpl implements PromotionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PromotionRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<Promotion>> watchPromotions(String commerceId) {
    return _firestore
        .collection('commerces')
        .doc(commerceId)
        .collection('promotions')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Promotion.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<List<Promotion>> getPromotions(String commerceId) async {
    try {
      final snapshot = await _firestore
          .collection('commerces')
          .doc(commerceId)
          .collection('promotions')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener promociones: $e');
    }
  }

  @override
  Future<Promotion?> getPromotion(String promotionId) async {
    try {
      final doc = await _firestore
          .collectionGroup('promotions')
          .where(FieldPath.documentId, isEqualTo: promotionId)
          .get();

      if (doc.docs.isEmpty) return null;

      return Promotion.fromMap({...doc.docs.first.data(), 'id': doc.docs.first.id});
    } catch (e) {
      throw Exception('Error al obtener la promoción: $e');
    }
  }

  @override
  Future<void> createPromotion(Promotion promotion) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await _firestore
          .collection('commerces')
          .doc(promotion.commerceId)
          .collection('promotions')
          .add(promotion.toMap());
    } catch (e) {
      throw Exception('Error al crear la promoción: $e');
    }
  }

  @override
  Future<void> updatePromotion(Promotion promotion) async {
    try {
      if (promotion.id == null) throw Exception('ID de promoción no válido');

      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await _firestore
          .collection('commerces')
          .doc(promotion.commerceId)
          .collection('promotions')
          .doc(promotion.id)
          .update(promotion.toMap());
    } catch (e) {
      throw Exception('Error al actualizar la promoción: $e');
    }
  }

  @override
  Future<void> deletePromotion(String promotionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final promotion = await getPromotion(promotionId);
      if (promotion == null) throw Exception('Promoción no encontrada');

      await _firestore
          .collection('commerces')
          .doc(promotion.commerceId)
          .collection('promotions')
          .doc(promotionId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar la promoción: $e');
    }
  }

  @override
  Future<void> updatePromotionStatus(String promotionId, PromotionStatus status) async {
    try {
      final promotion = await getPromotion(promotionId);
      if (promotion == null) throw Exception('Promoción no encontrada');

      await _firestore
          .collection('commerces')
          .doc(promotion.commerceId)
          .collection('promotions')
          .doc(promotionId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar el estado de la promoción: $e');
    }
  }

  @override
  Future<void> incrementUsedCount(String promotionId) async {
    try {
      final promotion = await getPromotion(promotionId);
      if (promotion == null) throw Exception('Promoción no encontrada');

      await _firestore
          .collection('commerces')
          .doc(promotion.commerceId)
          .collection('promotions')
          .doc(promotionId)
          .update({
        'usedCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error al incrementar el contador de uso: $e');
    }
  }
} 