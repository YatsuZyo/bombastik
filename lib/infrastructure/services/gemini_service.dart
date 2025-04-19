import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBgQc1iGs1VnS5G8VBkW-qh_WDk4NF3Xq4'
  );
  
  late final GenerativeModel _model;
  late ChatSession _chat;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    try {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topP: 0.8,
          topK: 40,
          maxOutputTokens: 2048,
        ),
      );
      _chat = _model.startChat(
        history: [
          Content.text(
            'Eres un asistente virtual amigable y servicial de Bombastik, una aplicación e-commerce de productos en liquidación perecederos, ofertas y más. '
            'Tu objetivo es ayudar a los usuarios con sus consultas de manera clara y concisa. '
            'Debes ser cordial pero profesional, y siempre mantener un tono positivo.'
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error al inicializar Gemini: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Respuesta vacía del modelo');
      }
      
      return response.text!;
    } catch (e) {
      debugPrint('Error en sendMessage: $e');
      if (e.toString().contains('not found for API version')) {
        return 'Lo siento, estamos experimentando problemas técnicos con el servicio. '
               'Por favor, intenta nuevamente en unos momentos.';
      }
      return 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.';
    }
  }

  void resetChat() {
    _initializeModel();
  }
} 