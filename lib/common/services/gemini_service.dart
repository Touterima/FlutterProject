import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAP9QzrB2yjj_J2EUWU0ozPfR3U710I4Ho'; 
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);
      return response.text ?? 'No response received';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> sendMessageWithContext(String message, String context) async {
    try {
      final fullMessage = '$context\n\nUser: $message';
      final content = Content.text(fullMessage);
      final response = await _chat.sendMessage(content);
      return response.text ?? 'No response received';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void resetChat() {
    _chat = _model.startChat();
  }
}