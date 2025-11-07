import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookbook/services/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookbook/main.dart';

void confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _performLogout(context);
              Navigator.of(context).pop();
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}

void _performLogout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
    } catch (e) {
      // ignore prefs errors
    }

    // Use global navigatorKey to avoid using BuildContext across async gaps
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthenticationUser()),
      (route) => false,
    );
  } catch (e) {
    debugPrint("Error signing out: $e");
  }
}
