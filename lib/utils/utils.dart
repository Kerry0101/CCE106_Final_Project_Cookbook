import 'package:flutter/material.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  void showSnackBar(String? text, Color backgroundColor) {
    if (text == null) return;
    final snackBar =
    SnackBar(content: Text(text), backgroundColor: backgroundColor);

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
