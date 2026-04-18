import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:pro_mini/utils/app_config.dart';

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Future<String> generateText(String prompt) async {
    final uri =
        Uri.parse(ApiConfig.generateContentUrl).replace(queryParameters: {
      'key': apiKey,
    });
    final payload = {
      "contents": [
        {
          "parts": [
            { "text": prompt }
          ]
        }
      ]
    };

    log('[GeminiService] generateText start');
    log('[GeminiService] request uri: $uri');
    log('[GeminiService] request payload: ${jsonEncode(payload)}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    log('[GeminiService] statusCode: ${response.statusCode}');
    log('[GeminiService] response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to generate text: ${response.body}');
    }
  }
}
