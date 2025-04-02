// lib/data/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyPhotoUrl = 'photoUrl';
  static const _keyOtherData = 'other_data'; // Ejemplo para otras keys

  // Guardar URL de imagen
  static Future<void> savePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhotoUrl, url);
  }

  // Obtener URL de imagen
  static Future<String?> getPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhotoUrl);
  }

  // Limpiar URL (al hacer logout)
  static Future<void> clearPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPhotoUrl);
  }

  // Ejemplo para otros datos
  static Future<void> saveSomeData(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyOtherData, value);
  }
}
