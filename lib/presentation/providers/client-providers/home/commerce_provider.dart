import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bombastik/domain/models/commerce.dart';

final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  return CommerceRepository();
});

class CommerceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Commerce>> getCommerces() {
    return _firestore
        .collection('commerces')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Commerce.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  Stream<List<Commerce>> getCommercesByCategory(String category) {
    return _firestore
        .collection('commerces')
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Commerce.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }
}

final commercesProvider = StreamProvider<List<Commerce>>((ref) {
  return ref.watch(commerceRepositoryProvider).getCommerces();
});

final commercesByCategoryProvider =
    StreamProvider.family<List<Commerce>, String>((ref, category) {
  return ref.watch(commerceRepositoryProvider).getCommercesByCategory(category);
}); 