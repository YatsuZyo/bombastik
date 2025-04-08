import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBgQc1iGs1VnS5G8VBkW-qh_WDk4NF3Xq4'
  );
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      return response.text ?? 'Lo siento, no pude procesar tu mensaje.';
    } catch (e) {
      debugPrint('Error en sendMessage: $e');
      return 'Error al procesar tu mensaje: $e';
    }
  }

  void resetChat() {
    _chat = _model.startChat();
  }
} 