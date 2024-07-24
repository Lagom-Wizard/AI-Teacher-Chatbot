import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqAiService {

  Future getLLaMA3Response(String prompt) async {
    const String endpoint = 'https://api.groq.com/openai/v1/chat/completions';

    final String teacherPrompt =
      "You are a teacher teaching grade 5 to grade 10. Explain the concept to a student: $prompt";

    final Map<String, dynamic> requestBody = {
      "model": "llama3-70b-8192",
      "messages":[{
        "role":"user",
        "content": teacherPrompt,
        }],
      "max_tokens":2048,
      "temperature":0.7,
      "top_p":1,
      "frequency_penalty":0,
      "presence_penalty":0,
      "response_format":{
        "type":"text"
      },
      "stream":false};

    final Map<String, String> headers = {
      "Authorization": "Bearer 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",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    final http.Response response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    return response;

  }
}
