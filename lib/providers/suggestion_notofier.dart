import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_mini/providers/chat_provider.dart';
import 'package:pro_mini/services/gemini_service.dart';

final suggestionProvider =
    StateNotifierProvider<SuggestionNotifier, List<String>>((ref) {
  final service = ref.watch(geminiProvider);
  return SuggestionNotifier(service);
});

class SuggestionNotifier extends StateNotifier<List<String>> {
  final GeminiService service;
  Timer? _debounce;

  SuggestionNotifier(this.service) : super([]);

  void onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (text.isEmpty) {
        state = [];
        return;
      }

      final prompt = buildPrompt(text);

      try {
        final response = await service.generateText(prompt);

        // Split response into list
        final suggestions = response
            .split("\n")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        state = suggestions;
      } catch (e) {
        state = [];
      }
    });
  }

  void clear() {
    state = [];
  }
}

String buildPrompt(String input) {
  return """
Give 5 short autocomplete suggestions for:
"$input"

Rules:
- very short (2-5 words)
- no numbering
- plain text list
""";
}