import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:image_picker/image_picker.dart';
import '../data/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool obscurePassword = true;
  String selectedImagePath = '';

  String selectedCountry = 'Sri Lanka';
  String selectedCode = '+94';

  String nameError = '';
  String emailError = '';
  String passwordError = '';
  String phoneError = '';

  final List<Map<String, String>> countries = [
    {'name': 'Sri Lanka', 'flag': '🇱🇰', 'code': '+94'},
    {'name': 'India', 'flag': '🇮🇳', 'code': '+91'},
    {'name': 'Pakistan', 'flag': '🇵🇰', 'code': '+92'},
    {'name': 'Bangladesh', 'flag': '🇧🇩', 'code': '+880'},
    {'name': 'Japan', 'flag': '🇯🇵', 'code': '+81'},
    {'name': 'China', 'flag': '🇨🇳', 'code': '+86'},
    {'name': 'USA', 'flag': '🇺🇸', 'code': '+1'},
    {'name': 'UK', 'flag': '🇬🇧', 'code': '+44'},
  ];

  InputDecoration inputStyle(String hint, {Widget? suffixIcon, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: (errorText != null && errorText.isNotEmpty) ? errorText : null,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA3B2),
        fontSize: 15,
      ),
      filled: true,
      fillColor: context.inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF1450F0), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImagePath = picked.path;
      });
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Profile Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF1450F0),
                  ),
                  title: const Text('Select from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickImageFromGallery();
                  },
                ),
                if (selectedImagePath.isNotEmpty)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text('Remove Image'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedImagePath = '';
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool validateForm() {
    nameError = '';
    emailError = '';
    passwordError = '';
    phoneError = '';
    setState(() {});
    return true;
  }

  Future<void> createAccount() async {
  if (!validateForm()) return;

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    AppState.isLoggedIn = true;

    AppState.userName = fullNameController.text.trim().isEmpty
        ? 'User'
        : fullNameController.text.trim();

    AppState.email = emailController.text.trim();

    AppState.phone = '$selectedCode ${phoneController.text.trim()}';

    AppState.imagePath = selectedImagePath;

    await AppState.saveState();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  } on FirebaseAuthException catch (e) {
    String message = 'Registration failed';

    if (e.code == 'email-already-in-use') {
      message = 'Email already in use';
    } else if (e.code == 'weak-password') {
      message = 'Password is too weak';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email address';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
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
              top: -70,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: blueDark,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: 60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: blueLight.withOpacity(0.75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: -100,
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: 260,
                  height: 180,
                  decoration: BoxDecoration(
                    color: blueLight.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: blueLight.withOpacity(0.28),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create\nAccount',
                    style: TextStyle(
                      fontSize: 42,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: showImageOptions,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8AB4FF),
                            width: 2,
                          ),
                          color: Colors.white.withOpacity(0.7),
                          image: selectedImagePath.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(File(selectedImagePath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImagePath.isEmpty
                            ? const Icon(
                                Icons.camera_alt_outlined,
                                size: 38,
                                color: Color(0xFF5E8EF7),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: fullNameController,
                    cursorColor: const Color(0xFF1450F0),
                    decoration: inputStyle('Full Name', errorText: nameError),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color(0xFF1450F0),
                    decoration: inputStyle('Email', errorText: emailError),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    cursorColor: const Color(0xFF1450F0),
                    decoration: inputStyle(
                      'Password',
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
                          color: const Color(0xFF7C8AA5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCountry,
                            borderRadius: BorderRadius.circular(16),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: countries.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['name'],
                                child: Text(
                                  '${country['flag']}  ${country['code']}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              final selected = countries.firstWhere(
                                (c) => c['name'] == value,
                              );
                              setState(() {
                                selectedCountry = selected['name']!;
                                selectedCode = selected['code']!;
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: const Color(0xFFD0D5DD),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            cursorColor: const Color(0xFF1450F0),
                            decoration: InputDecoration(
                              hintText: 'Your number',
                              errorText: phoneError.isNotEmpty ? phoneError : null,
                              hintStyle: const TextStyle(
                                color: Color(0xFF9AA3B2),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
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
                          color: Color(0xFF8B95A7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}