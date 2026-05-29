import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'theme.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/products.dart';
import 'screens/cart.dart';
import 'screens/profile.dart';
import 'screens/checkout.dart';
import 'data/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await AppState.loadState();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          themeMode: currentMode,

          theme: ThemeData(
            scaffoldBackgroundColor: context.bgColor,

            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFF1450F0),
              selectionColor: Color(0x661450F0),
              selectionHandleColor: Color(0xFF1450F0),
            ),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1450F0),
              brightness: Brightness.light,
            ),
          ),

          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF121212),

            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFF1450F0),
              selectionColor: Color(0x661450F0),
              selectionHandleColor: Color(0xFF1450F0),
            ),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1450F0),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
          ),

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return _buildRoute(const Welcome());

              case '/login':
                return _buildRoute(const Login());

              case '/register':
                return _buildRoute(const Register());

              case '/home':
                return _buildRoute(const Home());

              case '/products':
                return _buildRoute(const Products());

              case '/cart':
                return _buildRoute(const Cart());

              case '/profile':
                return _buildRoute(const Profile());

              case '/checkout':
                return _buildRoute(const Checkout());

              default:
                return _buildRoute(const Welcome());
            }
          },

          initialRoute: AppState.isLoggedIn ? '/home' : '/',
        );
      },
    );
  }
}