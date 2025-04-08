import 'package:bombastik/domain/repositories/profile_repository.dart';
import 'package:bombastik/domain/repositories/profile_repository_impl.dart';
import 'package:bombastik/infrastructure/services/imgbb_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imgBBServiceProvider = Provider<ImgBBService>((ref) {
  return ImgBBService(
    apiKey: '9106f089320713928b1662d1c6fdafab',
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.read(imgBBServiceProvider),
    FirebaseFirestore.instance,
  );
});
