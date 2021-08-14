import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

class WeMeetToast {
  static void toast(String message, [bool error = false]) {
    BotToast.showText(
      text: message,
      contentColor: Colors.black,
      borderRadius: BorderRadius.circular(5.0),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12.0
      ),
      duration: Duration(seconds: error ? 4 : 2)
    );
  }
}