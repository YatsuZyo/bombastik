// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para login con email y contraseña (específico para clientes)
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Método para login con Google (existente)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;
      if (user == null) return null;

      // Verificar si el usuario ya existe en Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      // Solo actualizar campos esenciales si es un nuevo usuario
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? googleUser.displayName,
          'name': user.displayName ?? googleUser.displayName,
          'role': 'cliente',
          'createdAt': FieldValue.serverTimestamp(),
          // Campos editables inicializados como null en lugar de vacío
          'phone': null,
          'address': null,
          'photoUrl': user.photoURL,
        });
      } else {
        // Para usuarios existentes, solo actualizar campos que podrían cambiar
        await _firestore.collection('users').doc(user.uid).update({
          'email': user.email,
          'displayName': user.displayName ?? googleUser.displayName,
          'photoUrl': user.photoURL,
        });
      }

      return user;
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      await _googleSignIn.signOut();
      await _auth.signOut();
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteUser() async {
    await _auth.currentUser?.delete();
  }

  // Método para verificar rol de usuario
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error al obtener rol: $e');
      return null;
    }
  }
}
