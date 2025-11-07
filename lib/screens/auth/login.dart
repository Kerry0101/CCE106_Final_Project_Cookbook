import 'package:cookbook/screens/auth/index.dart';
import 'package:cookbook/screens/auth/signup.dart';
import 'package:cookbook/screens/home.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:cookbook/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  bool _isGoogleSigningIn = false;
  final ScrollController _scrollController = ScrollController();
  final Utils utils = Utils();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }


  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool('remember_me') ?? false;
      if (saved) {
        final email = prefs.getString('saved_email') ?? '';
        if (!mounted) return;
        setState(() {
          rememberMe = true;
          _email.text = email;
        });
      }
    } catch (e) {
      debugPrint('loadSavedEmail error: $e');
    }
  }

  
  Future<void> _userLogIn() async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!(userCredential.user?.emailVerified ?? false)) {
        utils.showSnackBar('Please verify your email before logging in', Colors.red);
        return;
      }

      // Save remember-me preference
      try {
        final prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          await prefs.setBool('remember_me', true);
          await prefs.setString('saved_email', _email.text.trim());
        } else {
          await prefs.remove('remember_me');
          await prefs.remove('saved_email');
        }
      } catch (e) {
        debugPrint('prefs error: $e');
      }

      if (!mounted) return;
      
      // Clear the entire navigation stack to avoid leftover dialogs
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      utils.showSnackBar(e.message ?? 'Authentication failed', Colors.red);
    } catch (e) {
      utils.showSnackBar('An error occurred', Colors.red);
      debugPrint('login error: $e');
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isGoogleSigningIn) return;
    setState(() => _isGoogleSigningIn = true);

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      
      // Navigate to home page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      utils.showSnackBar(e.message ?? 'Google Sign-In failed', Colors.red);
    } catch (e) {
      utils.showSnackBar('An error occurred during Google Sign-In', Colors.red);
      debugPrint('Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => _isGoogleSigningIn = false);
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [bgc1, bgc2, bgc3, bgc4],
          ),
        ),
        child: SafeArea(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context, 
                      SlidePageRoute(
                        page: const IndexPage(),
                        direction: AxisDirection.right,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Center(child: Image.asset('lib/images/iconpng.png', height: 160, width: 160)),
                  const SizedBox(height: 8.0),
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('loginPasswordField'),
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              key: const Key('loginPasswordToggle'),
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(value: rememberMe, onChanged: (v) => setState(() => rememberMe = v ?? false)),
                            const Text('Remember me'),
                            const Spacer(),
                            TextButton(onPressed: () {}, child: const Text('Forgot password?')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoggingIn
                                ? null
                                : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _userLogIn();
                              }
                                },
                            child: _isLoggingIn
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Log In'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // "or" divider
                        Row(
                          children: [
                            Expanded(child: Divider(thickness: 1, color: Colors.grey[400])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('or', style: TextStyle(color: Colors.grey[600])),
                            ),
                            Expanded(child: Divider(thickness: 1, color: Colors.grey[400])),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Google Sign-In button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isGoogleSigningIn ? null : _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[700],
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[300]!, width: 1),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: _isGoogleSigningIn
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'lib/images/button_icons/google.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sign-In with Google',
                                        style: GoogleFonts.lato(
                                          color: Colors.grey[700],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context, 
                                SlidePageRoute(
                                  page: const SignUp(),
                                  direction: AxisDirection.left,
                                ),
                              ), 
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}