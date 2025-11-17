import 'package:cookbook/screens/auth/signup.dart';
import 'package:cookbook/screens/home.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:cookbook/utils/page_transitions.dart';
import 'package:cookbook/utils/validators.dart';
import 'package:cookbook/utils/error_messages.dart';
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
        utils.showWarning(
          'Please verify your email address before signing in. Check your inbox for the verification link.',
        );
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
      utils.showError(ErrorMessages.getAuthErrorMessage(e));
    } catch (e) {
      utils.showError(ErrorMessages.getGeneralErrorMessage(e));
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
        String displayName = googleUser.displayName ?? '';
        
        // If Google doesn't provide a display name, prompt user to enter one
        if (displayName.isEmpty) {
          displayName = await _promptForUsername(context) ?? 'User';
        }
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'displayName': displayName,
          'name': googleUser.displayName ?? displayName,
          'email': googleUser.email,
          'photoURL': googleUser.photoUrl ?? userCredential.user?.photoURL,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Check if existing user has displayName, if not prompt for it
        if (userDoc.data()?['displayName'] == null || userDoc.data()?['displayName'] == '') {
          final displayName = await _promptForUsername(context) ?? userDoc.data()?['name'] ?? 'User';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
            'displayName': displayName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Update existing user's photo if they don't have one
        if (userDoc.data()?['photoURL'] == null && googleUser.photoUrl != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
            'photoURL': googleUser.photoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;
      
      // Navigate to home page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      utils.showError(ErrorMessages.getAuthErrorMessage(e));
    } catch (e) {
      utils.showError(
        'Unable to sign in with Google. Please try again or use email sign-in.',
      );
      debugPrint('Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => _isGoogleSigningIn = false);
    }
  }

  Future<String?> _promptForUsername(BuildContext context) async {
    final TextEditingController usernameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Your Username',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter a username to display in the app',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: usernameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: const Icon(Icons.account_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Username must be at least 2 characters';
                  }
                  if (value.trim().length > 30) {
                    return 'Username must be less than 30 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9 _-]+$').hasMatch(value.trim())) {
                    return 'Username can only contain letters, numbers, spaces, _ and -';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, usernameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => Validators.email(value),
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => Validators.phone(value, isRequired: true),
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => Validators.verificationCode(value),
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
                        utils.showSuccess(
                          ErrorMessages.getSuccessMessage('password_reset_sent'),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      utils.showError(ErrorMessages.getAuthErrorMessage(e));
                    } catch (e) {
                      utils.showError(
                        ErrorMessages.getGeneralErrorMessage(e),
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
                          utils.showError(
                            'No account found with this phone number. Please check your phone number and try again, or use email reset instead.',
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
                            utils.showError(
                              ErrorMessages.getAuthErrorMessage(e),
                            );
                          },
                          codeSent: (String verId, int? resendToken) {
                            setState(() {
                              codeSent = true;
                              verificationId = verId;
                            });
                            utils.showSuccess(
                              'Verification code sent to your phone!',
                            );
                          },
                          codeAutoRetrievalTimeout: (String verId) {
                            verificationId = verId;
                          },
                          timeout: const Duration(seconds: 60),
                        );
                      } catch (e) {
                        utils.showError(
                          ErrorMessages.getGeneralErrorMessage(e),
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
                          utils.showError(
                            'No account found with this phone number. Please check and try again.',
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
                          utils.showSuccess(
                            ErrorMessages.getSuccessMessage('password_reset_sent'),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        utils.showError(
                          ErrorMessages.getAuthErrorMessage(e),
                        );
                      } catch (e) {
                        utils.showError(
                          ErrorMessages.getGeneralErrorMessage(e),
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
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Enter your email address',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) => Validators.email(v),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) => Validators.password(v),
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