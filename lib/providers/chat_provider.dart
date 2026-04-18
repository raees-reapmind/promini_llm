import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_mini/models/message.dart';
import 'package:pro_mini/services/gemini_service.dart';

final geminiProvider = Provider<GeminiService>(
  (ref) {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API Key is not set in .env file");
    }
    return GeminiService(apiKey);
  },
);

class ChatNotifier extends StateNotifier<List<Message>> {
  final GeminiService geminiService;

  ChatNotifier(this.geminiService) : super([]);

  bool isLoading = false;

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    log('[ChatNotifier] sendMessage text="$text"');
    state = [...state, Message(text: text, isUser: true)];
    isLoading = true;
    try {
      final response = await geminiService.generateText(text);
      log('[ChatNotifier] generateText response="$response"');
      state = [...state, Message(text: response, isUser: false)];
    } catch (e, st) {
      log('[ChatNotifier] sendMessage error: $e', stackTrace: st);
      state = [
        ...state,
        Message(text: "Error: ${e.toString()}", isUser: false)
      ];
    } finally {
      isLoading = false;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  final geminiService = ref.watch(geminiProvider);
  return ChatNotifier(geminiService);
});

final isLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
