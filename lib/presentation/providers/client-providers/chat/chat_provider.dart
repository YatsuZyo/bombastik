import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/chat_message.dart';
import 'package:bombastik/infrastructure/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.read(geminiServiceProvider));
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;

  ChatNotifier(this._geminiService) : super([]) {
    // Mensaje inicial del asistente
    state = [
      ChatMessage.assistant(
        '¡Hola! Soy tu asistente virtual de Bombastik. ¿En qué puedo ayudarte hoy?',
      ),
    ];
  }

  Future<void> sendMessage(String message) async {
    // Agregar mensaje del usuario
    state = [...state, ChatMessage.user(message)];

    // Agregar mensaje de carga
    state = [...state, ChatMessage.loading()];

    try {
      // Obtener respuesta de Gemini
      final response = await _geminiService.sendMessage(message);

      // Reemplazar mensaje de carga con la respuesta
      state =
          state
              .map(
                (msg) => msg.isLoading ? ChatMessage.assistant(response) : msg,
              )
              .toList();
    } catch (e) {
      // Reemplazar mensaje de carga con mensaje de error
      state =
          state
              .map(
                (msg) =>
                    msg.isLoading
                        ? ChatMessage.assistant(
                          'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta nuevamente.',
                        )
                        : msg,
              )
              .toList();
    }
  }

  void clearChat() {
    _geminiService.resetChat();
    state = [
      ChatMessage.assistant(
        '¡Hola! Soy tu asistente virtual de Bombastik. ¿En qué puedo ayudarte hoy?',
      ),
    ];
  }
}
