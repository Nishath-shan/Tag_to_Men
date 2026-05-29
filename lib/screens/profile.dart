import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/app_state.dart';
import '../widgets/app_bottom_nav.dart';
import '../theme.dart';
import 'order_history.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        AppState.imagePath = picked.path;
      });

      await AppState.saveState();
      await AppState.saveUserProfileToFirestore();    }
  }

  void copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: context.inputFillColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void showEditProfileDialog() {
    final nameController =
        TextEditingController(text: AppState.userName);

    final emailController =
        TextEditingController(text: AppState.email);

    final phoneController =
        TextEditingController(text: AppState.phone);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: context.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: pickImageFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1450F0),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Change Image'),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: nameController,
                    decoration: inputStyle('Name'),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: emailController,
                    decoration: inputStyle('Email'),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: phoneController,
                    decoration: inputStyle('Phone'),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {

                            setState(() {
                              AppState.userName =
                                  nameController.text.trim();

                              AppState.email =
                                  emailController.text.trim();

                              AppState.phone =
                                  phoneController.text.trim();
                            });

                            await AppState.saveState();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1450F0),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFF1450F0),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final imageProvider =
        AppState.imagePath.isNotEmpty
            ? FileImage(File(AppState.imagePath))
            : null;

    return Scaffold(
      backgroundColor: context.bgColor,

      bottomNavigationBar:
          const AppBottomNav(currentIndex: 3),

      appBar: AppBar(
        backgroundColor: context.bgColor,
        foregroundColor: context.textColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(16, 8, 16, 20),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: context.highlightBgColor,
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,

                  children: [

                    Container(
                      width: 110,
                      height: 130,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius:
                            BorderRadius.circular(18),

                        image: imageProvider != null
                            ? DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),

                      child: imageProvider == null
                          ? const Icon(
                              Icons.person,
                              size: 54,
                              color: Color(0xFF1450F0),
                            )
                          : null,
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.end,

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            AppState.userName,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  context.textColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            AppState.phone.isEmpty
                                ? 'No phone added'
                                : AppState.phone,
                            style: TextStyle(
                              color:
                                  context.iconColor,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            height: 42,

                            child: ElevatedButton(
                              onPressed:
                                  showEditProfileDialog,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                        0xFF1450F0),
                                foregroundColor:
                                    Colors.white,
                              ),

                              child: const Text(
                                'Edit Profile',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,

              builder:
                  (context, currentMode, _) {

                final isDark =
                    currentMode == ThemeMode.dark;

                return menuItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',

                  onTap: () {
                    themeNotifier.value =
                        isDark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                  },

                  trailing: Switch(
                    value: isDark,

                    onChanged: (val) {
                      themeNotifier.value =
                          val
                              ? ThemeMode.dark
                              : ThemeMode.light;
                    },

                    activeColor:
                        const Color(0xFF1450F0),
                  ),
                );
              },
            ),

            menuItem(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const OrderHistory(),
                  ),
                );
              },
            ),

            menuItem(
              icon: Icons.share_outlined,
              title: 'Share App',

              onTap: () {
                copyText(
                  'https://play.google.com/store/apps/details?id=com.example.tagtomen',
                  'App link',
                );
              },
            ),

            menuItem(
              icon: Icons.call_outlined,
              title: 'Contact',

              onTap: () {
                copyText(
                    '0767926070',
                    'Phone number');
              },
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                onPressed: () async {

                  await FirebaseAuth.instance
                      .signOut();

                  await AppState.resetUserData();

                  if (!context.mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1450F0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}