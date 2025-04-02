import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(id).set(data);
  }

  Future<DocumentSnapshot> getDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).get();
  }
}
