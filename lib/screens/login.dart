import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme.dart';
import '../data/app_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String emailError = '';
  String passwordError = '';

  InputDecoration inputStyle(
    String hint, {
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: (errorText != null && errorText.isNotEmpty) ? errorText : null,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA3B2),
        fontSize: 16,
      ),
      filled: true,
      fillColor: context.inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF1450F0), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  bool validateForm() {
    emailError = '';
    passwordError = '';

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      emailError = 'Email is required';
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
    }

    setState(() {});
    return emailError.isEmpty && passwordError.isEmpty;
  }

  Future<void> loginUser() async {
    if (!validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      AppState.isLoggedIn = true;
      AppState.email = userCredential.user?.email ?? emailController.text.trim();
      AppState.userName = 'User';
      AppState.password = '';
      await AppState.saveState();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'invalid-credential') {
        message = 'Email or password is wrong';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blueDark = Color(0xFF1450F0);
    const blueLight = Color(0xFFAEDBFF);
    const cream = Color(0xFFFAFAFA);
    final textDark = context.textColor;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -110,
              left: -45,
              child: Container(
                width: 290,
                height: 290,
                decoration: const BoxDecoration(
                  color: blueDark,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -20,
              left: 135,
              child: Container(
                width: 180,
                height: 250,
                decoration: BoxDecoration(
                  color: blueLight.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(140),
                ),
              ),
            ),
            Positioned(
              top: 190,
              right: -35,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF2EA7FF).withOpacity(0.95),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(height: 170),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Good to see you back!',
                    style: TextStyle(
                      fontSize: 18,
                      color: context.subTextColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputStyle(
                      'Type your email',
                      errorText: emailError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: inputStyle(
                      'Type your password',
                      errorText: passwordError,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}