import 'dart:io';
import 'package:bombastik/domain/repositories/profile_repository.dart';
import 'package:bombastik/infrastructure/services/imgbb_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ImgBBService imgBBService;
  final FirebaseFirestore firestore;

  ProfileRepositoryImpl(this.imgBBService, this.firestore);

  @override
  Future<String?> uploadProfileImage(File imageFile) async {
    return await imgBBService.uploadImage(imageFile);
  }

  @override
  Future<String?> getProfileImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await firestore.collection('users').doc(user.uid).get();
    return doc.data()?['photoUrl'] as String?;
  }
}
