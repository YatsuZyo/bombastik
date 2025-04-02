import 'dart:io';

abstract class ProfileRepository {
  Future<String?> uploadProfileImage(File imageFile); // Eliminar userId
  Future<String?> getProfileImageUrl(); // Eliminar parámetro
}
