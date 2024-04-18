import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> showNotification(
      BuildContext context, String message, bool error) async {
    Flushbar(
      icon: Icon(
        error ? Icons.error_outline : Icons.info_outline,
        color: Colors.white,
        size: 30,
      ),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
      message: message,
      messageSize: 18,
      titleText: Text(error ? "Error" : "Success",
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: Colors.white)),
    ).show(context);
  }
}
