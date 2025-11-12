import 'package:cookbook/screens/auth/signup.dart';
import 'package:cookbook/screens/home.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:cookbook/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Create a fresh GoogleSignIn instance to avoid cached credentials
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Aggressively clear any cached account
      try {
        await googleSignIn.disconnect();
      } catch (e) {
        // Disconnect may fail if not connected, that's okay
        debugPrint('Disconnect error (expected): $e');
      }
      await googleSignIn.signOut();
      
      // Trigger the Google Sign-In flow - this should now show account picker
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
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
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Check if user document exists in Firestore, if not create it
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      if (!userDoc.exists) {
        // Create user document for new Google Sign-In users
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': googleUser.displayName ?? 'User',
          'email': googleUser.email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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

  Future<void> _showForgotPasswordDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isEmailMode = true;
    bool codeSent = false;
    String verificationId = '';

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Reset Password',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle buttons for Email/Phone
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isEmailMode = true;
                              codeSent = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isEmailMode ? primaryColor : Colors.transparent,
                            foregroundColor: isEmailMode ? Colors.white : primaryColor,
                          ),
                          child: const Text('Email'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isEmailMode = false;
                              codeSent = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !isEmailMode ? primaryColor : Colors.transparent,
                            foregroundColor: !isEmailMode ? Colors.white : primaryColor,
                          ),
                          child: const Text('Phone'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Mode
                  if (isEmailMode) ...[
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                  
                  // Phone Mode
                  if (!isEmailMode) ...[
                    Text(
                      codeSent 
                        ? 'Enter the verification code sent to your phone.'
                        : 'Enter your phone number to receive a verification code.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    if (!codeSent)
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+1234567890',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!value.startsWith('+')) {
                            return 'Phone must start with country code (e.g., +1)';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    if (codeSent)
                      TextFormField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Verification Code',
                          hintText: '123456',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the code';
                          }
                          if (value.length != 6) {
                            return 'Code must be 6 digits';
                          }
                          return null;
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  if (isEmailMode) {
                    // Email reset logic
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: emailController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        utils.showSnackBar(
                          'Password reset email sent! Check your inbox.',
                          Colors.green,
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      String message = 'Failed to send reset email';
                      if (e.code == 'user-not-found') {
                        message = 'No account found with this email';
                      } else if (e.code == 'invalid-email') {
                        message = 'Invalid email address';
                      } else if (e.code == 'too-many-requests') {
                        message = 'Too many requests. Please try again later';
                      }
                      utils.showSnackBar(message, Colors.red);
                    } catch (e) {
                      utils.showSnackBar(
                        'An error occurred. Please try again.',
                        Colors.red,
                      );
                    }
                  } else {
                    // Phone reset logic
                    if (!codeSent) {
                      // First, check if phone number exists in database
                      try {
                        final phoneNumber = phoneController.text.trim();
                        
                        // Query Firestore to check if phone number exists
                        final usersSnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .where('phone', isEqualTo: phoneNumber)
                            .limit(1)
                            .get();
                        
                        if (usersSnapshot.docs.isEmpty) {
                          utils.showSnackBar(
                            'No account found with this phone number. Please check and try again.',
                            Colors.red,
                          );
                          return;
                        }
                        
                        // Phone number exists, now send verification code
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: phoneNumber,
                          verificationCompleted: (PhoneAuthCredential credential) async {
                            // Auto-verification (Android only)
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            utils.showSnackBar(
                              e.message ?? 'Verification failed',
                              Colors.red,
                            );
                          },
                          codeSent: (String verId, int? resendToken) {
                            setState(() {
                              codeSent = true;
                              verificationId = verId;
                            });
                            utils.showSnackBar(
                              'Verification code sent to your phone!',
                              Colors.green,
                            );
                          },
                          codeAutoRetrievalTimeout: (String verId) {
                            verificationId = verId;
                          },
                          timeout: const Duration(seconds: 60),
                        );
                      } catch (e) {
                        utils.showSnackBar(
                          'Failed to verify phone number. Please try again.',
                          Colors.red,
                        );
                      }
                    } else {
                      // Verify code and find user
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(
                          verificationId: verificationId,
                          smsCode: codeController.text.trim(),
                        );
                        
                        // Find user by phone number in Firestore
                        final usersSnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .where('phone', isEqualTo: phoneController.text.trim())
                            .limit(1)
                            .get();
                        
                        if (usersSnapshot.docs.isEmpty) {
                          utils.showSnackBar(
                            'No account found with this phone number',
                            Colors.red,
                          );
                          return;
                        }
                        
                        final userEmail = usersSnapshot.docs.first.get('email');
                        
                        // Send password reset email
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: userEmail,
                        );
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          utils.showSnackBar(
                            'Password reset link sent to your email!',
                            Colors.green,
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        utils.showSnackBar(
                          e.message ?? 'Invalid verification code',
                          Colors.red,
                        );
                      } catch (e) {
                        utils.showSnackBar(
                          'An error occurred. Please try again.',
                          Colors.red,
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isEmailMode 
                  ? 'Send Reset Link' 
                  : (codeSent ? 'Verify Code' : 'Send Code'),
              ),
            ),
          ],
        ),
      ),
    );
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
                            TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: const Text('Forgot password?'),
                            ),
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