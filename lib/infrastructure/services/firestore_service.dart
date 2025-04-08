// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('Guardando documento en colección $collection con id $id');
      await _firestore.collection(collection).doc(id).set(data);
      print('Documento guardado exitosamente');
    } catch (e) {
      print('Error al guardar documento: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).get();
  }
}
