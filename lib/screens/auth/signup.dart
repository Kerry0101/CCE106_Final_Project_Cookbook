import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/main.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:cookbook/utils/page_transitions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/screens/auth/login.dart';

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
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _age = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final ScrollController _scrollController = ScrollController();
  Utils utils = Utils();

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

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

      // Calculate age from date of birth if provided
      int? calculatedAge;
      if (_selectedDate != null) {
        final today = DateTime.now();
        calculatedAge = today.year - _selectedDate!.year;
        if (today.month < _selectedDate!.month || 
            (today.month == _selectedDate!.month && today.day < _selectedDate!.day)) {
          calculatedAge--;
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'age': calculatedAge ?? int.tryParse(_age.text),
        'gender': _selectedGender,
        'role': 'user', // Default role for new users
        'createdAt': FieldValue.serverTimestamp(),
      });

      utils.showSnackBar("Please verify your email before logging in", Colors.blue);

      // use navigatorKey for navigation after async gaps to avoid
      // use_build_context_synchronously warnings
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const LogIn()));
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      utils.showSnackBar(e.message, Colors.red);
      Navigator.of(context).pop(); // Close loading dialog
    } catch (e) {
      debugPrint(e.toString());
      utils.showSnackBar("An error occurred during registration", Colors.red);
      Navigator.of(context).pop(); // Close loading dialog
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // ~18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 4745)), // ~13 years ago
      helpText: 'Select your date of birth',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Auto-calculate age when date is selected
        final today = DateTime.now();
        int calculatedAge = today.year - picked.year;
        if (today.month < picked.month || 
            (today.month == picked.month && today.day < picked.day)) {
          calculatedAge--;
        }
        _age.text = calculatedAge.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _age.dispose();
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
                        page: const LogIn(),
                        direction: AxisDirection.right,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Center(child: Image.asset('lib/images/iconpng.png', height: 160, width: 160)),
                  const SizedBox(height: 8.0),
                  Text(
                    'Create Account',
                    style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name field
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email field
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Date of Birth field
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            hintText: _selectedDate == null 
                                ? 'Select your date of birth' 
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Age field (auto-populated from date of birth)
                        TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            prefixIcon: Icon(Icons.cake),
                            hintText: 'Age will be calculated from date of birth',
                          ),
                          readOnly: _selectedDate != null,
                          validator: (value) {
                            if (_selectedDate == null && (value == null || value.isEmpty)) {
                              return 'Please enter your age or select date of birth';
                            }
                            if (_selectedDate == null && value != null) {
                              final age = int.tryParse(value);
                              if (age == null || age < 13 || age > 120) {
                                return 'Please enter a valid age (13-120)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Gender field
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: _genderOptions.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password field
                        TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
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
                        const SizedBox(height: 16),
                        
                        // Confirm Password field
                        TextFormField(
                          controller: _confirmPassword,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _password.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Terms and conditions checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value!;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'I agree with Terms and Privacy Policy',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        
                        // Sign Up button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!rememberMe) {
                                utils.showSnackBar('Please agree to Terms and Privacy Policy', Colors.red);
                                return;
                              }
                              userSignUp();
                            },
                            child: const Text('Create Account'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Already have an account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context, 
                                SlidePageRoute(
                                  page: const LogIn(),
                                  direction: AxisDirection.right,
                                ),
                              ), 
                              child: const Text('Sign In'),
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
