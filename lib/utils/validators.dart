class Validators {
  static String? requiredField(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введите Email';
    final emailReg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailReg.hasMatch(value)) {
      return 'Введите корректный Email';
    }
    return null;
  }

  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно';
    }
    final nameReg = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s-]+$');
    if (!nameReg.hasMatch(value)) {
      return '$fieldName должно содержать только буквы';
    }
    if (value.trim().length < 2) {
      return '$fieldName слишком короткое';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    var body = digits;
    if ((body.startsWith('7') || body.startsWith('8')) && body.length > 1) {
      body = body.substring(1);
    }
    if (body.isEmpty) return null;
    if (body.length < 10) return 'Введите номер полностью';
    return null;
  }

  static String? validateLength(String? value, {int min = 0, int max = 255}) {
    if (value == null) return null;
    if (value.length < min) return 'Минимум $min символов';
    if (value.length > max) return 'Максимум $max символов';
    return null;
  }

  static String? validateOrganizationName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Название обязательно';
    }

    final nameReg = RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9\s"\-.,№\(\)«»]+$');
    if (!nameReg.hasMatch(value)) {
      return 'Недопустимые символы';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Адрес обязателен';
    }

    final addressReg = RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9\s,\-\.\/\(\)]+$');

    if (!addressReg.hasMatch(value)) {
      return 'Недопустимые символы в адресе';
    }

    if (value.length < 10) {
      return 'Адрес слишком короткий';
    }
    return null;
  }
}
