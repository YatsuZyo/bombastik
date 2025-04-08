// providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para obtener el brillo del sistema
final systemBrightnessProvider = Provider<Brightness>((ref) {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
});

// Provider para el modo del tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  SharedPreferences? _prefs;

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedTheme = _prefs?.getString(_key);
      if (savedTheme != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error al cargar tema: $e');
    }
  }

  void toggleTheme() {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newTheme;
    _saveTheme(newTheme);
  }

  void setSystemTheme() {
    state = ThemeMode.system;
    _saveTheme(ThemeMode.system);
  }

  Future<void> _saveTheme(ThemeMode theme) async {
    try {
      await _prefs?.setString(_key, theme.toString());
    } catch (e) {
      debugPrint('Error al guardar tema: $e');
    }
  }
}
