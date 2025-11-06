import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  } catch (e) {
    print("Error signing out: $e");
  }
}
