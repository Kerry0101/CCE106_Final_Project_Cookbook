import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/main.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/screens/auth/login.dart';  // Assuming you have a Login page in the auth folder

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool rememberMe = false;
  bool _obscurePassword = true;
  // no scroll controller here; keep default SingleChildScrollView behavior
  Utils utils = Utils();

  // Sign up method with email verification
  void userSignUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // Show loading dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      await userCredential.user!.sendEmailVerification();


      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _name.text,
        'email': _email.text,
      });

      utils.showSnackBar("Please verify your email before logging in", Colors.blue);

      // use navigatorKey for navigation after async gaps to avoid
      // use_build_context_synchronously warnings
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const LogIn()));
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      utils.showSnackBar(e.message, Colors.red);
    }
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        utils.showSnackBar("Email verified! Proceeding to home.", Colors.green);
        navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        utils.showSnackBar('Please verify your email before logging in', Colors.red);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    checkEmailVerified();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              bgc1,
              bgc2,
              bgc3,
              bgc4,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 3, 0, 0),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => const LogIn()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.asset(
                    'lib/images/icon.jpg',
                    height: 300,
                    width: 300,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  "Create Account",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: UnderlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value != null && value.length < 6
                            ? 'Enter minimum 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Column(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Text(
                            'I agree with Terms and Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            userSignUp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                        ],
                      ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
