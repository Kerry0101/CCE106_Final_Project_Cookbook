import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cookbook/screens/home.dart';
import 'package:cookbook/screens/auth/login.dart';
import 'package:cookbook/screens/auth/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationUser extends StatefulWidget {
  const AuthenticationUser({super.key});

  @override
  State<AuthenticationUser> createState() => _AuthenticationUserState();
}

class _AuthenticationUserState extends State<AuthenticationUser> {
  bool? _isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    setState(() {
      _isFirstTime = !hasSeenOnboarding;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking first time status
    if (_isFirstTime == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If first time, show onboarding
    if (_isFirstTime == true) {
      _completeOnboarding(); // Mark as seen
      return const OnboardingPage();
    }

    // Otherwise, check authentication state
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LogIn();
          }
        },
      ),
    );
  }
}
