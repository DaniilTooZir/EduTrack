import 'package:flutter/material.dart';

class MessengerHelper {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  static void showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  static void showInfo(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  static void showWarning(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[800],
      ),
    );
  }
}
