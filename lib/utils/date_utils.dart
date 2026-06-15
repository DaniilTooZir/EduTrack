import 'package:flutter/material.dart';

/// 'dd.MM.yyyy'
String formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// 'dd.MM'
String formatShortDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

/// 'HH:mm' из DateTime
String formatTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// 'HH:mm' из TimeOfDay
String formatTimeOfDay(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// 'HH:mm:00' — поля времени в бэкэнде, требующие ввода секунд
String formatTimeOfDaySec(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

/// Безопасно обрезает строку времени до 'HH:mm'. Не падает при строке < 5 символов.
String formatTimeStr(String t) => t.length >= 5 ? t.substring(0, 5) : t;
