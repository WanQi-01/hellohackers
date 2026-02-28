import 'dart:convert';
import 'package:http/http.dart' as http;
import '../chat_message.dart';


class ApiService {
  static const String baseUrl = 'https://api-cqohnaeeea-uc.a.run.app/chat';

  /// Send a message to your AI backend
  /// Generate a unique session key for each user
  static Future<String> sendMessage(
        String message,
        String sessionKey,
      ) async {

        // JSON payload
          Map<String, dynamic> payload = {
            'chat': message,
            'sessionKey': sessionKey,
          };

          try {
            final response = await http.post(
              Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            );

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              return data['reply'] ?? "No reply from AI";
            } else {
              // print('Server error: ${response.statusCode}');
              return "Server error";
            }
          } catch (e) {
              // print('Error sending message: $e');
            return "Error sending message";
          }
        }

}


