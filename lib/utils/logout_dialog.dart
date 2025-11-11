import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cookbook/services/authentication.dart';
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
    // Create fresh GoogleSignIn instance to clear cache
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    
    // Aggressively disconnect from Google (clears cache)
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      debugPrint("Disconnect error (expected if not signed in with Google): $e");
    }
    
    // Sign out from Google
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    
    // Sign out from Firebase Auth
    await FirebaseAuth.instance.signOut();
    
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthenticationUser()),
      (route) => false,
    );
  } catch (e) {
    debugPrint("Error signing out: $e");
  }
}
