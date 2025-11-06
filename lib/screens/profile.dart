import 'package:flutter/material.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PROFILE PAGE"),
      ),
      body: const Center(
        child: Text("Profile page"),
      ),
    );
  }
}
