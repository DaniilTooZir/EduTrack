import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static final String apiKey = dotenv.env['RESEND_API_KEY']!;
  static const String senderEmail = 'daniilzyraev500@gmail.com';
  static Future<void> sendEmail({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    final uri = Uri.parse('https://api.resend.com/emails');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'from': senderEmail,
        'to': [to],
        'subject': subject,
        'html': htmlContent,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 202) {
      print('Письмо отправлено на $to');
    } else {
      print('Ошибка при отправке письма: ${response.statusCode}');
      print(response.body);
    }
  }
}