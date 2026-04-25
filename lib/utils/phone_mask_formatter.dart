import 'package:flutter/services.dart';

class PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldBody = _extractBody(oldValue.text);
    var newBody = _extractBody(newValue.text);
    if (newBody.length == oldBody.length && newValue.text.length < oldValue.text.length && newBody.isNotEmpty) {
      newBody = newBody.substring(0, newBody.length - 1);
    }
    if (newBody.length > 10) newBody = newBody.substring(0, 10);
    final text = _buildMasked(newBody);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  static String format(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';
    return _buildMasked(_extractBody(phone));
  }

  static String _extractBody(String text) {
    var digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if ((digits.startsWith('7') || digits.startsWith('8')) && digits.length > 1) {
      digits = digits.substring(1);
    } else if (digits == '7' || digits == '8') {
      digits = '';
    }
    return digits.length > 10 ? digits.substring(0, 10) : digits;
  }

  static String _buildMasked(String body) {
    if (body.isEmpty) return '';
    final result = StringBuffer('+7 ');
    for (int i = 0; i < body.length; i++) {
      if (i == 0) result.write('(');
      result.write(body[i]);
      if (i == 2) {
        result.write(') ');
      } else if (i == 5) {
        result.write('-');
      } else if (i == 7) {
        result.write('-');
      }
    }
    return result.toString();
  }
}
