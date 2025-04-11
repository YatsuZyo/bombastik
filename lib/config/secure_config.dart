/// Archivo de configuración seguro para claves API sensibles.
/// Este archivo NO debe ser incluido en el control de versiones.
/// 
/// Para usar este archivo:
/// 1. Copia este archivo a secure_config.dart
/// 2. Reemplaza los valores con tus claves API reales
/// 3. Asegúrate de que secure_config.dart esté en .gitignore

class SecureConfig {
  // Gemini API
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBgQc1iGs1VnS5G8VBkW-qh_WDk4NF3Xq4',
  );

  // ImgBB API
  static const String imgBBApiKey = String.fromEnvironment(
    'IMGBB_API_KEY',
    defaultValue: '9106f089320713928b1662d1c6fdafab',
  );

  // Firebase API Keys
  static const String firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyBLMHCdLmnYMF997X_-0N3ODNjDB5B8eWM',
  );

  static const String firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: 'AIzaSyA2Wo0REpje-G7P-7KkPAsFGnmXfE3g8Ng',
  );

  static const String firebaseIosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
    defaultValue: 'AIzaSyC4_XbGPJvPt663DumJwGUxnAPCK7hn8Y8',
  );
} 